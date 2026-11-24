//
//  WorkoutRow.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/14/22.
//

import SwiftUI

struct WorkoutRow: View {
    let model: WorkoutViewModel
    
    init(workout: Workout, unit: UnitLength) {
        self.model = WorkoutViewModel(workout: workout, unit: unit)
    }
    
    var body: some View {
        HStack(spacing: 24) {
            DateBlock(date: model.workout.startDate)

            VStack(alignment: .leading) {
                Text(model.formattedDistance)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color.Theme.primary)
                HStack(spacing: 4) {
                    Text(model.formattedDuration)
                    Text("•")                            
                    Text(model.formattedSpeed)
                }
                .foregroundStyle(Color.Theme.accentSecondary)
                .font(.subheadline.weight(.semibold))
            }
        }
        .listRowBackground(Color.Theme.appBackground)
    }
}

#Preview("Miles", traits: .app, .sizeThatFitsLayout) {
    List {
        WorkoutRow(workout: MockHealthProvider.sampleWorkout, unit: .miles)
    }
    .themedList()
}

#Preview("Kilometers", traits: .app, .sizeThatFitsLayout) {
    List {
        WorkoutRow(workout: MockHealthProvider.sampleWorkout, unit: .kilometers)
    }
    .themedList()
}
