//
//  HealthResult.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 1/28/22.
//

import Foundation
import HealthKit
import OSLog

struct HealthResult {
    var workouts: [Workout]
    var unit: UnitLength
    var cached: Bool
    var anchor: HKQueryAnchor?
    
    static var empty: HealthResult {
        HealthResult(workouts: [], unit: Locale.current.distanceUnit(), cached: true, anchor: nil)
    }
    
    private static let logger = Logger(subsystem: "BikeLog", category: "Workout cache")

    func applying(added: [Workout], deleted: [UUID], newAnchor: HKQueryAnchor) -> Self {
        var byID: [UUID: Workout] = [:]
        // An unanchored query starts a new snapshot, not a delta against the cache.
        if anchor != nil {
            for workout in workouts { byID[workout.id] = workout }
        }
        for workout in added { byID[workout.id] = workout }
        for id in deleted { byID.removeValue(forKey: id) }
        return Self(workouts: Array(byID.values), unit: unit, cached: false, anchor: newAnchor)
    }
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
            
        
        do {
            if let data = try container.decodeIfPresent(Data.self, forKey: .anchor) {
                anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
                if anchor == nil { Self.logger.error("Cached query anchor was unreadable; will rebuild.") }
            } else {
                anchor = nil
            }
        } catch {
            Self.logger.error("Cached query anchor was unreadable; will rebuild.")
            anchor = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cached, forKey: .cached)
        try container.encode(workouts, forKey: .workouts)

        let unitData = try NSKeyedArchiver.archivedData(withRootObject: unit, requiringSecureCoding: true)
        try container.encode(unitData, forKey: .unit)
        
        if let anchor = anchor {
            let anchorData = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            try container.encodeIfPresent(anchorData, forKey: .anchor)
        }
    }
    
}
