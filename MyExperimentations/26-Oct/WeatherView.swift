//
//  WeatherView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/26/25.
//

import SwiftUI
import Combine

final class WeatherViewModel: ObservableObject {
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var temperature: String = "--"
    @Published var state: State = .idle
    
    enum State: Equatable {
        case idle, isLoading, success, error(String)
    }
    
    private var weatherTask: Task<Void, Never>? = nil
    
    // MARK: async/await approach(❌ всё смешано: UI логика + Combine в init)
    @MainActor
    func fetchWeather(lat: String, lng: String) {
        weatherTask?.cancel()
        
        weatherTask = Task {
            state = .isLoading
            try? await Task.sleep(nanoseconds: 300_000_000)
           
            do {
                let weatherTemp = try await fetchWeatherAsync(lat: lat, lng: lng)
                print("There you go: \(weatherTemp)")
                
                temperature =  String(weatherTemp.current_weather.temperature)
                
                state = .success
            } catch  {
                if Task.isCancelled { return }
                state = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: 2) turn into async/await (❌ не отменяется, нет await, не thread-safe)
    private func fetchWeatherAsync(lat: String, lng: String) async throws -> WeatherResponse {
        
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lng)&current_weather=true") else { throw URLError(.badURL) }
        
        // URLSession
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weather
    }
    
    // MARK: DEPRECATED
//    private func fetchWeatherCombine() {
//        // ❌ всё смешано: UI логика + Combine в init
//        $city
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] city in
//                guard let self = self, !city.isEmpty else { return }
//                self.fetchWeather(for: city)
//            }
//            .store(in: &cancellables)
//    }
    
    // MARK: DEPRECATED
    // ❌ не отменяется, нет await, не thread-safe
//    func fetchWeather(for city: String) {
//        isLoading = true
//        error = nil
//        
//        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=51.51&longitude=-0.13&current_weather=true"
//        guard let url = URL(string: urlString) else {
//            self.error = "Invalid URL"
//            return
//        }
//        
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.isLoading = false
//                if case let .failure(err) = completion {
//                    self?.error = err.localizedDescription
//                }
//            }, receiveValue: { [weak self] response in
//                self?.temperature = "\(response.current_weather.temperature)°C"
//            })
//            .store(in: &cancellables)
//    }
    
    deinit {
        weatherTask?.cancel()
    }
}

struct WeatherResponse: Decodable {
    struct Current: Decodable {
        let temperature: Double
    }
    let current_weather: Current
}


struct WeatherView: View {
    @StateObject private var vm = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // latLngInut
                latLngInputs
                
                // convert to enum
                switch vm.state {
                case .isLoading:
                    ProgressView("Loading...")
                case .success:
                    Text("Temperature: \(vm.temperature)")
                        .font(.largeTitle)
                case .error(let string):
                    Text(string)
                        .foregroundColor(.red)
                default:
                    EmptyView()
                }
                
                Spacer()
        
            }
            .navigationTitle("Weather Lookup")
            .padding()
        }
    }
    
    @ViewBuilder
    private var latLngInputs: some View {
        // 42.842071
        TextField("Enter latitude...", text: $vm.latitude)
            .inputFieldStyle()
        //74.567473
        TextField("Enter longitude...", text: $vm.longitude)
            .inputFieldStyle()
        
        Button("Get tempreture") {
            vm.fetchWeather(lat: vm.latitude, lng: vm.longitude)
        }
        .buttonStyle(.borderedProminent)
        .disabled(vm.state == .isLoading)
        .animation(.easeInOut, value: vm.state)
    }
}

extension View {
    func inputFieldStyle() -> some View {
        self.textFieldStyle(RoundedBorderTextFieldStyle())
            .disableAutocorrection(true)
    }
}


#Preview {
    WeatherView()
}
