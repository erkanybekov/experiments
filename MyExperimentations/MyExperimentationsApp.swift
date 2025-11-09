//
//  dummyApp.swift
//  dummy
//
//  Created by Erlan Kanybekov on 9/23/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        
        /// Как я упоминал ранее, фреймворк BackgroundTasks жестко требует, чтобы регистрация задач (BGTaskScheduler.shared.register) выполнялась только один раз за жизненный цикл приложения
        BackgroundImageFetchService.shared.registerTasks() // MARK: Вот так будет правильно (refence: service.registerTasks() on vm)
        return true
    }

    // Показываем уведомление в foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}


@main
struct MyExperimentationsApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var body: some Scene {
        WindowGroup {
            AudioRecorderView()
        }
    }
}
