////
////  LocalNotificationService.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/28/25.
////
//
//
//import UserNotifications
//
//final class LocalNotificationService {
//    // MARK: shared and center
//    static let shared = LocalNotificationService()
//    var center = UNUserNotificationCenter.current()
//        
//    // MARK: request permission and check for authorization
//    func requestPermission() async -> Bool {
//        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
//        
////        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
////            DispatchQueue.main.async {
////                self.permissionGranted = granted
////            }
////            if let error = error {
////                print("Error requesting permission: \(error.localizedDescription)")
////            }
////        }
//    }
//    
//    func isAuthorized() async -> Bool {
//        let settings = await center.notificationSettings()
//        return settings.authorizationStatus == .authorized
//    }
//    
//    // MARK: Schedule
//    func schedule(id: String, title: String, body: String, seconds: Double) async throws {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = .default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
//        let request = UNNotificationRequest (identifier: id, content: content, trigger: trigger)
//        
//        try await center.add(request)
//    }
//    
//    // MARK: cancel and clear
//    func cancel(id: String) {
//        center.removePendingNotificationRequests(withIdentifiers: [id])
//    }
//    
//    func clearAll() {
//        center.removeAllDeliveredNotifications()
//    }
//    
////    func scheduleNotification(title: String, body: String, seconds: Double) {
////        let content = UNMutableNotificationContent()
////        content.title = title
////        content.body = body
////        content.sound = .default
////
////        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
////        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
////
////        UNUserNotificationCenter.current().add(request) { error in
////            if let error = error {
////                print("Error scheduling: \(error.localizedDescription)")
////            } else {
////                print("✅ Scheduled: \(title)")
////            }
////        }
////    }
//}
