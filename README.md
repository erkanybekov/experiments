# Background Image Fetch with BGTaskScheduler

## BackgroundImageFetchScheduling

Golden-standard сервис для фонового обновления изображений с использованием `BGTaskScheduler`.

```swift
import BackgroundTasks
import Foundation
import UIKit

protocol BackgroundImageFetchScheduling {
    /// Регистрация фоновых задач
    func registerTasks()
    
    /// Планирование следующего обновления через заданный интервал
    func scheduleRefresh(after interval: TimeInterval)
    
    /// Обработка задачи при срабатывании
    func handleRefresh(task: BGAppRefreshTask)
    
    /// Асинхронный запрос нового изображения
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
        // Перепланируем задачу сразу
        scheduleRefresh(after: 10) // ~10 секунд
        
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
```

### 🔹 Зачем и когда использовать

- **Используется для:** фонового обновления контента, который не требует немедленного отображения пользователю, например:
  - Кеширование изображений;
  - Синхронизация данных с сервером;
  - Обновление виджетов.

- **Особенности:**
  - iOS сама решает, когда выполнять задачу, исходя из ресурсов и энергопотребления.
  - Нельзя гарантировать точное время выполнения (например, через 10 секунд).
  - Может не сработать, если приложение активно и обновляет данные при старте (foreground fetch).

- **Когда бесполезен:**  
  Если приложение всегда загружает актуальные данные при запуске или пока находится в foreground — BGTaskScheduler почти не нужен, так как система сама не даст гарантии частого или точного выполнения.  
