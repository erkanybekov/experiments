//
//  BackgroundImageFetchScheduling.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/28/25.
//


import BackgroundTasks
import Foundation
import UIKit

protocol BackgroundImageFetchScheduling {
    func registerTasks()
    func scheduleRefresh(after interval: TimeInterval)
    func handleRefresh(task: BGAppRefreshTask)
    func fetchDogImage() async throws -> DogImage
}

final class BackgroundImageFetchService: BackgroundImageFetchScheduling {
    nonisolated static let shared = BackgroundImageFetchService()
    private init() {}
    
    private let refreshIdentifier = "kg.erkan.myexperimentations.imageFetch"
    
    func registerTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshIdentifier, using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleRefresh(after interval: TimeInterval) {
        let request = BGAppRefreshTaskRequest(identifier: refreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Failed to schedule image fetch task:", error)
        }
    }
    
    func handleRefresh(task: BGAppRefreshTask) {
        // перепланируем сразу
        scheduleRefresh(after: 10) // ~10 сек
        
        task.expirationHandler = {
            // Очистка ресурсов или отмена операций
            task.setTaskCompleted(success: false)
        }
        
        Task {
            do {
                let dog = try await fetchDogImage()
                print("✅ New dog image: \(dog.message)")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Fetch failed:", error)
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    func fetchDogImage() async throws -> DogImage {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let dogImage = try JSONDecoder().decode(DogImage.self, from: data)
        
        return dogImage
    }
}

struct DogImage: Codable {
    let message: String
    let status: String
}
