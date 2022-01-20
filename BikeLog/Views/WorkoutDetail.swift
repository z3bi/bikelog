//
//  WorkoutDetail.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 1/19/22.
//

import SwiftUI

struct WorkoutDetail: View {
    let workout: Workout
    var body: some View {
        Text("Under Construction")
    }
}

struct WorkoutDetail_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetail(workout: MockHealthProvider().generateWorkout(activity: .cycling))
    }
}
