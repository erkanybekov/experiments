////
////  NotificationView.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/28/25.
////
//
//
//import SwiftUI
//
//struct NotificationView: View {
//    @State private var viewModel = RefNotificationViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                content
//                
//                controllers()
//            }
//            .padding()
//            .navigationTitle("Local Notifications")
//        }
//    }
//    
//    @ViewBuilder
//    private var content: some View {
//        TextField("Message", text: $viewModel.body)
//            .commonTextFieldStyle()
//        
//        Button("Start") {
//            Task {
//                await viewModel.startTimerNotification(title: "Manual", body: viewModel.body)
//            }
//        }
//        .buttonStyle(.borderedProminent)
//        
//        Text("\(max(Int(Double(viewModel.seconds) * (1 - viewModel.progress)), 0))s")
//            .font(.system(size: 36, weight: .medium, design: .rounded))
//            .monospacedDigit()
//        
//        Spacer()
//    }
//    
//    private func controllers() -> some View {
//        Stepper("Set the timer") {
//            viewModel.seconds += 1
//        } onDecrement: {
//            viewModel.seconds -= 1
//        }
//    }
//}
//
//extension View {
//    func commonTextFieldStyle() -> some View {
//        self.textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding(.horizontal)
//    }
//}
//
//#Preview {
//    NotificationView()
//}
