//
//  TimerViewModel.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/27/25.
//

import Combine
import SwiftUI


@Observable
final class TimerViewModel {
    var seconds = 15
    var state: State = .idle
    var progress: Double = 0.0

    private var timerTask: Task<Void, Never>? = nil
    
    enum State { case idle, scheduled, delivered }

    private var startDate: Date?

    @MainActor
    func startTimerNotification() async {
        guard await NotificationServiceSmelly.shared.isAuthorized() else {
            let _ = await NotificationServiceSmelly.shared.requestPermission()
            return
        }
        
        timerTask?.cancel()
        progress = 0
        
        state = .scheduled
        startDate = Date()
        
        // schedule notification
        try? await NotificationServiceSmelly.shared.schedule(
            id: "notification.one",
            title: "Scheduled notification",
            body: "Wtf man this is best practice",
            after: TimeInterval(seconds)
        )
        
        // progress task
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && progress < 1.0 {
                // elapsed
                let elapsed = Date().timeIntervalSince(startDate!)
                
                progress = min(elapsed / Double(seconds), 1.0)
                
                if progress >= 1.0 {
                    state = .delivered
                    break
                }
                try? await Task.sleep(nanoseconds: 200_000_000) // check 5 раз в секунду
            }
        }
    }

    @MainActor
    func cancel() {
        timerTask?.cancel()
        progress = 0
        state = .idle
        startDate = nil
    }

    deinit {
        timerTask?.cancel()
    }
}
