//
//  LogHeader.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import SwiftUI

struct LogHeader: View {
    @ObservedObject var manager: WorkoutManager
    let models: [StatsViewModel]

    init(manager: WorkoutManager) {
        self.manager = manager
        self.models = StatisticalPeriod.allCases.map {
            StatsViewModel(date: Date(),
                           period: $0,
                           type: manager.type,
                           unit: manager.unit,
                           workouts: manager.workouts)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(models, id: \.self) { model in
                HStack {
                    Text(model.title)
                        .textCase(.uppercase)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.Theme.darkGreen)
                    Text(model.totalDistance())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.Theme.teal)
                    Text(model.workoutCount())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.Theme.gray)
                }
            }
            Picker("Sort", selection: $manager.sort) {
                ForEach(WorkoutSort.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct StatHeader_Previews: PreviewProvider {
    static var previews: some View {
        LogHeader(manager: WorkoutManager.mock())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
