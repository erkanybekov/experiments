//
//  Event.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/2/25.
//

import SwiftUI

// ❌ Smelly Model -> Clear ✅

struct Day: Identifiable {
    let id = UUID()
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let events: [Event]
    
    var hasEvent: Bool { !events.isEmpty }
}

struct Event: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let date: Date
    let color: Color // using String instead of Color
}
