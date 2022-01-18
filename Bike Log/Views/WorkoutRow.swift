//
//  WorkoutRow.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/14/22.
//

import SwiftUI

struct WorkoutRow: View {
    
    let model: WorkoutViewModel
    
    init(workout: Workout) {
        self.model = WorkoutViewModel(workout: workout)
    }
    
    var body: some View {
        HStack {
            DateBlock(date: model.workout.startDate)
            
            Spacer().frame(width: 15)
            
            VStack(alignment: .leading) {
                Text(model.formattedDistance)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.Theme.teal)
                HStack(spacing: 4) {
                    Text(model.formattedDuration)
                    Text("•")
                    Text(model.formattedSpeed)
                }
                .foregroundColor(.Theme.orange)
                .font(.system(size: 14, weight: .semibold))
            }
        }
    }
}

struct WorkoutRow_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(WorkoutType.allCases, id: \.self) { type in
            WorkoutRow(workout: MockHealthProvider().generateWorkout(type: type))
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .previewDisplayName(type.name)
        }
    }
}
