//
//  RefactoringCombineView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/23/25.
//

import SwiftUI
import Combine

/// TIMER
final class RefactoringCombineViewModel: ObservableObject {
    @Published var seconds: Int = 0
    @Published var state: CurrentState = .idle
    
    enum CurrentState {
        case idle
        case isRunning
        case Stopped
    }
    
    private var timerTask: Task<Void, Never>? = nil
    
    @MainActor
    func startTimer() {
        guard state != .isRunning else { return }
        state = .isRunning
        
        timerTask?.cancel()
        
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                seconds += 1
            }
        }
    }
    
    @MainActor
    func stopTimer() {
        state = .Stopped
        timerTask?.cancel()
    }
    
    @MainActor
    func resetTimer()  {
        stopTimer()
        seconds = 0
    }
}

struct RefactoringCombineView: View {
    var body: some View {
        CountDownView()
    }
}

struct CountDownView: View {
    @StateObject var vm = RefactoringCombineViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Seconds: \(vm.seconds)")
                .font(.largeTitle)
            
            HStack {
                Button(vm.state == .isRunning ? "stop" : "start") {
                    vm.state == .isRunning ? vm.stopTimer() : vm.startTimer()
                }
                
                Button("Reset") { vm.resetTimer() }

            }
        }
        .padding()
    }
}

#Preview {
    RefactoringCombineView()
}
