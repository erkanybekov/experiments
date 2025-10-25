//
//  SearchView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/25/25.
//

import SwiftUI
import Combine

final class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var state: State = .idle
    
    enum State {
        case idle
        case loading
        case error(String)
        case success
    }
    
    private var usersTask: Task<Void, Never>? = nil
    
    @MainActor
    func fetchUsersAsync() {
        usersTask?.cancel()
        
        usersTask = Task {
            state = .loading
            
            do {
                let result = try await fetchUserViaAsync()
                print("you are here: \(result)")
                users = result
                state = .success
            } catch  {
                if Task.isCancelled { return }
                state = .error(error.localizedDescription)
            }
        }
    }
    
    private func fetchUserViaAsync() async throws -> [User] {
        // url(can return nil)
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { throw URLError(.badURL) }
        
        // urlsession
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // jsonDecoder
        return try JSONDecoder().decode([User].self, from: data)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: COMBINE needs to be async/await
//    func fetchUsers() {
//        state = .loading
//        
//        URLSession.shared.dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/users")!)
//            .map(\.data)
//            .decode(type: [User].self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    self?.state = .error(error.localizedDescription)
//                case .finished:
//                    self?.state = .success
//                }
//            } receiveValue: { [weak self] users in
//                self?.users = users
//            }
//            .store(in: &cancellables)
//    }
    
    deinit {
        usersTask?.cancel()
    }
}

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

struct UsersView: View {
    @StateObject var vm = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                currentStateView
                Button("Load Users") { vm.fetchUsersAsync() }
                    .padding()
            }
            .navigationTitle("Users")
        }
    }
    
    @ViewBuilder
    private var currentStateView: some View {
        switch vm.state {
        case .idle:
            Text("Tap to load users")
        case .loading:
            ProgressView()
        case .success:
            listOfUsers
        case .error(let message):
            Text("Error: \(message)").foregroundColor(.red)
        }
    }
    
    private var listOfUsers: some View {
        List {
            ForEach(vm.users) { user in
                LazyVStack(alignment: .leading) {
                    Text(user.name).bold()
                    Text(user.email).font(.caption)
                }
            }
        }
    }
}


#Preview {
    UsersView()
}
