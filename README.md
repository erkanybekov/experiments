# Golden Practice: NotificationService

Сервис для работы с локальными уведомлениями на iOS с использованием `async/await`.

```swift
final class NotificationService {
    // MARK: Shared instance and UNUserNotificationCenter
    static let shared = NotificationService()
    var center = UNUserNotificationCenter.current()
    
    // MARK: Request permission and check authorization
    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
    
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: Schedule a notification
    func schedule(id: String, title: String, body: String, after seconds: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    // MARK: Cancel and clear notifications
    func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func clearAll() {
        center.removeAllDeliveredNotifications()
    }
}
```
