//
//  Measurement.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation

func / (lhs: Measurement<UnitLength>, rhs: Measurement<UnitDuration>) -> Measurement<UnitSpeed> {
    let quantity = lhs.converted(to: .meters).value / rhs.converted(to: .seconds).value
    let resultUnit = UnitSpeed.metersPerSecond
    return Measurement(value: quantity, unit: resultUnit)
}

extension UnitSpeed {
    static let secondsPerMeter = UnitSpeed(symbol: "s/m", converter: UnitConverterInverse())
    static let minutesPerMile = UnitSpeed(symbol: "min/mi", converter: UnitConverterInverse(multiplier: 0.44704 * 60))
    static let minutesPerKilometer = UnitSpeed(symbol: "min/km", converter: UnitConverterInverse(multiplier: 0.277778 * 60))
}

extension UnitLength {
    var speedUnit: UnitSpeed {
        switch self {
        case .miles:
            return .milesPerHour
        case .kilometers:
            return .kilometersPerHour
        default:
            return .metersPerSecond
        }
    }
    
    var paceUnit: UnitSpeed {
        switch self {
        case .miles:
            return .minutesPerMile
        case .kilometers:
            return .minutesPerKilometer
        default:
            return .secondsPerMeter
        }
    }
}

class UnitConverterInverse: UnitConverter {
    
    let multiplier: Double
    
    init(multiplier: Double = 1) {
        self.multiplier = multiplier
    }
    
    override func baseUnitValue(fromValue value: Double) -> Double {
        return multiplier/value
    }
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return multiplier/baseUnitValue
    }
}


typealias SpeedFormat = Measurement<UnitSpeed>.FormatStyle
typealias LengthFormat = Measurement<UnitLength>.FormatStyle

extension SpeedFormat {
    static func speedFormat(fractions: Int = 1) -> SpeedFormat {
        .measurement(width: .abbreviated,
                     usage: .asProvided,
                     numberFormatStyle: .number.precision(.fractionLength(fractions)))
    }
}

extension LengthFormat {
    static func lengthFormat(fractions: Int = 2) -> LengthFormat {
        .measurement(width: .abbreviated,
                     usage: .asProvided,
                     numberFormatStyle: .number.precision(.fractionLength(fractions)))
    }
}
