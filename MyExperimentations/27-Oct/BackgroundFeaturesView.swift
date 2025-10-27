//
//  BackgroundFeaturesView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/27/25.
//

import SwiftUI

import SwiftUI

struct BackgroundFeaturesView: View {
    @State private var selection: Feature? = nil

    enum Feature: String, Identifiable, CaseIterable {
        case localNotifications = "Local Notifications"
        case silentPush = "Silent Push"
        case liveActivities = "Live Activities"
        case bgTaskScheduler = "BGTaskScheduler"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            List(Feature.allCases) { feature in
                Button(feature.rawValue) {
                    selection = feature
                }
            }
            .navigationTitle("iOS Background Features")
            .sheet(item: $selection) { feature in
                featureView(feature)
            }
        }
    }

    @ViewBuilder
    private func featureView(_ feature: Feature) -> some View {
        switch feature {
        case .localNotifications:
            TimerView()
        case .silentPush:
            SilentPushExampleView()
        case .liveActivities:
            LiveActivitiesExampleView()
        case .bgTaskScheduler:
            BGTaskExampleView()
        }
    }
}

// MARK: - Placeholder Views
struct SilentPushExampleView: View { var body: some View { Text("Silent Push Example") } }
struct LiveActivitiesExampleView: View { var body: some View { Text("Live Activities Example") } }
struct BGTaskExampleView: View { var body: some View { Text("BG Task Scheduler Example") } }


#Preview {
    BackgroundFeaturesView()
}
