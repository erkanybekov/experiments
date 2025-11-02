////
////  NotificationViewModel.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/28/25.
////
//
//
//import SwiftUI
//
//@Observable
//class RefNotificationViewModel {
//    var body = ""
//    var state: State = .idle
//    var seconds = 5
//    var progress = 0.0
//    var startDate: Date? = nil
//    
//    enum State: Equatable {
//        case idle, running, delivered
//    }
//    
//    func startTimerNotification(title: String, body: String) async {
//        // check for Permission
//        guard await LocalNotificationService.shared.isAuthorized() else {
//            let _ = await LocalNotificationService.shared.requestPermission()
//            return
//        }
//        
//        state = .running
//        progress = 0.0
//        
//        startDate = Date()
//        // Schedule
//        try? await LocalNotificationService.shared.schedule(
//            id: "manual",
//            title: title,
//            body: body,
//            seconds: TimeInterval(seconds))
//        
//        Task {
//            while !Task.isCancelled && progress < 1.0 {
//                let elapsed = Date().timeIntervalSince(startDate!)
//                
//                progress = min(elapsed / Double(seconds), 1.0)
//                
//                if progress >= 1.0 {
//                    state = .delivered
//                    break
//                }
//                try? await Task.sleep(nanoseconds: 200_000_000) // check 5 раз в секунду
//            }
//        }
//    }
//}
