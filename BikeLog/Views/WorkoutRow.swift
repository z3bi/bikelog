//
//  WorkoutRow.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/14/22.
//

import SwiftUI

struct WorkoutRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: WorkoutViewModel
    
    init(workout: Workout) {
        self.model = WorkoutViewModel(workout: workout)
    }
    
    var body: some View {
        let rowLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 24))
        let metricsLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 4))

        rowLayout {
            DateBlock(date: model.workout.startDate)

            VStack(alignment: .leading) {
                Text(model.formattedDistance)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color.Theme.teal)
                metricsLayout {
                    Text(model.formattedDuration)
                    if !dynamicTypeSize.isAccessibilitySize {
                        Text("•")
                            .accessibilityHidden(true)
                    }
                    Text(model.formattedSpeed)
                }
                .foregroundStyle(Color.Theme.orange)
                .font(.subheadline.weight(.semibold))
            }
        }
    }
}

#Preview("Cycling", traits: .sizeThatFitsLayout) {
    WorkoutRow(workout: MockHealthProvider().generateWorkout(activity: .cycling))
        .padding()
}

#Preview("Running", traits: .sizeThatFitsLayout) {
    WorkoutRow(workout: MockHealthProvider().generateWorkout(activity: .running))
        .padding()
}

#Preview("Walking", traits: .sizeThatFitsLayout) {
    WorkoutRow(workout: MockHealthProvider().generateWorkout(activity: .walking))
        .padding()
}
