//
//  TimerView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/27/25.
//

import SwiftUI


struct TimerView: View {
    @State private var vm = TimerViewModel()
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: Header
            header
            
            // MARK: Timer Circle
            timerSchedule
            
            // MARK: Control Buttons
            controlButtons
            
            // MARK: State Info
            Text(stateText)
                .font(.headline)
                .foregroundStyle(progressColor)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Local Notifications")
    }
    
    private var header: some View {
        VStack(spacing: 10) {
            Text("Local Notification Timer")
                .font(.title.bold())
            
            Stepper("Timer") {
                vm.seconds += 1
            } onDecrement: {
                vm.seconds -= 1
            }

        }
    }
    
    private var timerSchedule: some View {
        ZStack {
            Circle().stroke(.gray.opacity(0.2), lineWidth: 10).frame(width: 160, height: 160)
            
            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 10, lineCap: .round)).frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: vm.progress)

            Text("\(max(Int(Double(vm.seconds) * (1 - vm.progress)), 0))s")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .monospacedDigit()
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button("Start") { Task { await vm.startTimerNotification() } }
                .disabled(vm.state == .scheduled)
            
            if vm.state == .scheduled {
                Button("Cancel") { vm.cancel() }
            }
        }
        .padding()
    }
    
    
    // MARK: Helpers
    
    var progressColor: Color {
        switch vm.state {
        case .idle: .gray
        case .scheduled: .blue
        case .delivered: .green
        }
    }
    
    var stateText: String {
        switch vm.state {
        case .idle: "Idle"
        case .scheduled: "Scheduled..."
        case .delivered: "Delivered 🎉"
        }
    }
}


#Preview {
    TimerView()
}
