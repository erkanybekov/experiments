//
//  RefactoringView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/23/25.
//

import SwiftUI
import Combine

/// LOGIN
final class RefactoringViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var age = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private func isUserEmailAgeEmpty() -> Bool {
        username.isEmpty || email.isEmpty || age.isEmpty
    }
    
    func save() async {
        try? await Task.sleep(nanoseconds: 800_000_000)
       
        if isUserEmailAgeEmpty() {
            alertMessage = "All fields are required!"
        } else if !email.contains("@") {
            alertMessage = "Email must be valid!"
        } else {
            alertMessage = "Profile saved for \(username)"
        }
        
        showAlert = true
    }
}

struct RefactoringView: View {
    @StateObject var vm = RefactoringViewModel()
    
    var body: some View {
        VStack {
            // extract as InputForm , ALSO: reapting modifiers
            ProfileFormView(
                username: $vm.username,
                email: $vm.email,
                age: $vm.age,
                save: { Task { await vm.save() }})
        }
        .padding()
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(vm.alertMessage),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct ProfileFormView: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var age: String
    
    let save: () -> Void
    
    var body: some View {
        Text("User Profile")
            .font(.largeTitle)
            .padding()
        
        VStack(spacing: 16) {
            Group {
                TextField("Enter username", text: $username)
                
                TextField("Enter email", text: $email)
                
                TextField("Enter age", text: $age)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
        }
        
        Button(action: save, label: {
            Text("Save")
                .commonButtonStyle()
        })
        .padding(.top)
    }
}

extension View {
    func commonInputStyle() -> some View {
        self.padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
    
    func commonButtonStyle() -> some View {
        self.foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
    }
}


#Preview {
    RefactoringView()
}
