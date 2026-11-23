//
//  Locale.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/18/22.
//

import Foundation

extension Locale {
    var distanceUnit: UnitLength {
        switch measurementSystem {
        case .us, .uk:
            return .miles
        default:
            return .kilometers
        }
    }
}
