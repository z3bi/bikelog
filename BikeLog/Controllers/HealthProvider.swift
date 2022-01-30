//
//  HealthProvider.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/11/22.
//

import Foundation
import Combine

protocol HealthProvider {
    func monitorWorkouts(activity: Activity) async
    func workoutsPublisher() -> AnyPublisher<HealthResult, Never>
}
