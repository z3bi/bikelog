//
//  WorkoutViewModel.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/15/22.
//

import Foundation

struct WorkoutViewModel {
    let workout: Workout
    
    var formattedDistance: String {
        workout.distance.formatted(LengthFormat.lengthFormat())
    }
    
    var formattedSpeed: String {
        switch workout.type {
        case .cycling:
            return workout.speed.formatted(SpeedFormat.speedFormat())
        case .running, .walking:
            let minutes = Int(workout.speed.value).formatted()
            let secondsValue = round((workout.speed.value - floor(workout.speed.value)) * 60)
            let seconds = Int(secondsValue).formatted()
            return String(format: String(localized: "%@'%@\"/%@"), minutes, seconds, workout.unit.symbol)
        }
    }
    
    var durationComponents: Set<Date.ComponentsFormatStyle.Field> {
        if workout.duration >= 60 * 60 {
            return [.hour, .minute]
        } else {
            return [.minute, .second]
        }
    }
    
    var durationRange: Range<Date> {
        workout.startDate..<(workout.startDate + workout.duration)
    }
    
    var formattedDuration: String {
        durationRange.formatted(.components(style: .condensedAbbreviated, fields: durationComponents))
    }
}
