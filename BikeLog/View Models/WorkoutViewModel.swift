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
        workout.speed.formatted(SpeedFormat.speedFormat())
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
