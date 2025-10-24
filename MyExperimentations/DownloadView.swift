//
//  DownloadView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/24/25.
//

import SwiftUI
import Combine

final class DownloadViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var state: State = .idle
    // MARK: Potential to be Enum
//    @Published var isDownloading: Bool = false
    // new
    
    enum State {
        case idle
        case isLoading
        case isError
        case isSuccess
        case stopped
    }
    
//    private var timer: AnyCancellable?
    private var timerTask: Task<Void, Never>? = nil
    
    func startDownloadAsync() {
        state = .isLoading
        
        timerTask?.cancel()
        
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                if progress < 1 {
                    progress += 0.02
                } else {
                    state = .isSuccess
                }
            }
        }
    }
        
    func stopDownloadAsync() {
        state = .stopped
        timerTask?.cancel()
    }
    
    func restart() {
        progress = 0.0
        stopDownloadAsync()
        startDownloadAsync()
    }
}


struct DownloadView: View {
    var body: some View {
        LinearLoadingView()
    }
}

struct LinearLoadingView: View {
    @StateObject var vm = DownloadViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(statusText)
                .onTapGesture {
                    if vm.state == .isSuccess { vm.restart() }
                }
            
            ProgressView(value: vm.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            
            Button(buttonText) {
                vm.state == .isLoading ? vm.stopDownloadAsync() : vm.startDownloadAsync()
            }
        }
        .padding()
        
    }
    // Not that clear
    private var buttonText: String {
        vm.state == .isLoading ? "Stop" : "Start"
    }
    
    private var statusText: String {
        switch vm.state {
        case .isLoading: "Loading"
        case .isError: "Oops"
        case .isSuccess: "It's done!, Click me to Restart"
        case .stopped: "Stopped"
        default: ""
        }
    }
}


#Preview {
    DownloadView()
}
