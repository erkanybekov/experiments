//
//  Item.swift
//  dummy
//
//  Created by Erlan Kanybekov on 9/23/25.
//

import Foundation
import SwiftData

@Model
final class ItemData {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

func loadJSONFromDocuments<T: Codable>(_ filename: String, as type: T.Type) -> T? {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentsPath.appendingPathComponent("\(filename).json")
    
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    } catch {
        print("Error loading JSON: \(error)")
        return nil
    }
}

actor JSONLoader {
    func loadLocalJSON<T: Codable>(_ filename: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Couldn't find \(filename).json in main bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ Couldn't parse \(filename).json: \(error)")
            return nil
        }
    }
}

struct DateTimeDTO: Codable {
    let year: Int?
    let month: Int?
    let day: Int?
    let hour: Int?
    let minute: Int?
    let seconds: Int?
    let milliSeconds: Int?
    let dateTime: String?
    let date: String?
    let time: String?
    let timeZone: String?
    let dayOfWeek: String?
    let dstActive: Bool?
}
