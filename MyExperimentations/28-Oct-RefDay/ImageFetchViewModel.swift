//
//  ImageFetchViewModel.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/28/25.
//


import Foundation
import Combine

@MainActor
final class ImageFetchViewModel: ObservableObject {
    @Published var imageURL: URL?
    @Published var lastFetchDate: Date?
    @Published var isScheduled = false

    private let service: BackgroundImageFetchScheduling

    init(service: BackgroundImageFetchScheduling = BackgroundImageFetchService.shared) {
        self.service = service
//        service.registerTasks()  // <-- MARK: ВОТ ТАК ДЕЛАТЬ НЕЛЬЗЯ 🚫
    }

    func scheduleImageFetch() {
        service.scheduleRefresh(after: 10) // через ~10 сек
        lastFetchDate = Date()
        isScheduled = true
    }

    func fetchImage() async {
        do {
            let dog = try await service.fetchDogImage()
            imageURL = URL(string: dog.message)
            lastFetchDate = Date()
            scheduleImageFetch()
        } catch {
            print("❌ Fetch failed:", error)
        }
    }
}
