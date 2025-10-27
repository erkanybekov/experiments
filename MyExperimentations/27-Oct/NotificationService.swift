//
//  NotificationService.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/27/25.
//
import UserNotifications

// MARK: REFACTORED
class NotificationServiceSmelly {
    // shared and current()
    static let shared = NotificationServiceSmelly()
    var center = UNUserNotificationCenter.current()

    // requestPermission and below authorize
    func requestPermission() async -> Bool {
        (( try? await center.requestAuthorization(options: [.alert, .sound])) ?? false)
        
        // MARK: DEPRECATED
//        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
//            if let error = error {
//                print("Error asking permission: \(error.localizedDescription)")
//            } else {
//                print("Permission granted: \(granted)")
//            }
//        }
    }
    
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // schedule
    func schedule(id: String, title: String, body: String, after seconds: TimeInterval) async throws{
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    // clear and cancel
    func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        
        // MARK: DEPRECATED
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        print("All notifications removed")
    }
    
    func clearAll() {
        center.removeAllDeliveredNotifications()
    }
    
    // ❌ Этот метод вызывается прямо из SwiftUI View
//    func showNotificationFromView() async {
//        async let req = await requestPermission()
//        async let notif: () = await schedule(id: UUID().uuidString, title: "Hi", body: "Hello again!", after: 5)
//    }
    
      //MARK: DEPRECATED
//    func sendNotificationAfter5Sec(title: String, body: String) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = .default
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        
//        center.add(request) { error in
//            if let error = error {
//                print("Error adding notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled!")
//            }
//        }
//    }
}


final class NotificationService {
    // MARK: shared and center
    static let shared = NotificationService()
    var center = UNUserNotificationCenter.current()
    
    // MARK: request permission and below authorization
    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
    
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: schedule
    func schedule(id: String, title: String, body: String, after seconds: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    // MARK: cancel and clear
    func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func clearAll() {
        center.removeAllDeliveredNotifications()
    }
}
