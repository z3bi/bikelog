//
//  HealthResult.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 1/28/22.
//

import Foundation
import HealthKit

struct HealthResult {
    var workouts: [Workout]
    var unit: UnitLength
    var cached: Bool
    var anchor: HKQueryAnchor?
    
    static var empty: HealthResult {
        HealthResult(workouts: [], unit: Locale.current.distanceUnit(), cached: true, anchor: nil)
    }
    
    private static let queue = DispatchQueue(label: "CachingQueue", qos: .default, attributes: .concurrent)
}
 
extension HealthResult: Codable {
    
    enum CodingKeys: String, CodingKey {
        case workouts, unit, cached, anchor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cached = try container.decode(Bool.self, forKey: .cached)
        workouts = try container.decode([Workout].self, forKey: .workouts)
        
        let unitData = try container.decode(Data.self, forKey: .unit)
        if let decodedUnit = try NSKeyedUnarchiver.unarchivedObject(ofClass: UnitLength.self, from: unitData) {
            unit = decodedUnit
        } else {
            throw DecodingError.valueNotFound(UnitLength.self, .init(codingPath: [CodingKeys.unit], debugDescription: "Unable to decode unit data"))
        }
            
        
        if let anchorData = try? container.decode(Data.self, forKey: .anchor),
           let decodedAnchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData) {
            anchor = decodedAnchor
        } else {
            anchor = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cached, forKey: .cached)
        try container.encode(workouts, forKey: .workouts)

        let unitData = try NSKeyedArchiver.archivedData(withRootObject: unit, requiringSecureCoding: false)
        try container.encode(unitData, forKey: .unit)
        
        if let anchor = anchor {
            let anchorData = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: false)
            try container.encodeIfPresent(anchorData, forKey: .anchor)
        }
    }
    
    static func fileName(activity: Activity) -> URL {
        let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return baseDir.appendingPathComponent(activity.rawValue)
    }
    
    func save(for activity: Activity) {
        HealthResult.queue.async {
            do {
                var cache = self
                cache.cached = true
                let fileName = HealthResult.fileName(activity: activity)
                let data = try JSONEncoder().encode(cache)
                try data.write(to: fileName)
            } catch {
                print("Error caching data: \(error)")
            }
        }
    }
    
    static func load(activity: Activity) async throws -> HealthResult {
        return try await withCheckedThrowingContinuation { continuation in
            HealthResult.queue.async {
                do {
                    let data = try Data(contentsOf: fileName(activity: activity))
                    let cache = try JSONDecoder().decode(HealthResult.self, from: data)
                    continuation.resume(returning: cache)
                } catch {
                    print("error loading cache: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
