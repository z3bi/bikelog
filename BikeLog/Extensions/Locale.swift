//
//  Locale.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/18/22.
//

import Foundation

extension Locale {
    var measurementSystem: String {
        (self as NSLocale).object(forKey: .measurementSystem) as? String ?? ""
    }
    
    func distanceUnit() -> UnitLength {
        if measurementSystem == Locale(identifier: "fr_FR").measurementSystem {
            return .kilometers
        } else {
            return .miles
        }
    }
}
