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
        workout.distance.formatted(WorkoutViewModel.lengthFormat)
    }
    
    var formattedSpeed: String {
        switch workout.type {
        case .cycling:
            return workout.speed.formatted(WorkoutViewModel.speedFormat)
        case .running, .walking:
            let minutes = Int(workout.speed.value).formatted()
            let secondsValue = round((workout.speed.value - floor(workout.speed.value)) * 60)
            let seconds = Int(secondsValue).formatted()
            return String(format: NSLocalizedString("%@'%@\"/%@", comment: ""), minutes, seconds, workout.unit.symbol)
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
    
    typealias SpeedFormat = Measurement<UnitSpeed>.FormatStyle
    static let speedFormat: SpeedFormat = .measurement(width: .abbreviated,
                                                       usage: .asProvided,
                                                       numberFormatStyle: .number.precision(.fractionLength(1)))

    typealias LengthFormat = Measurement<UnitLength>.FormatStyle
    static let lengthFormat: LengthFormat = .measurement(width: .abbreviated,
                                                           usage: .asProvided,
                                                           numberFormatStyle: .number.precision(.fractionLength(2)))
}
