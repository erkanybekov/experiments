//
//  Item.swift
//  dummy
//
//  Created by Erlan Kanybekov on 9/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
