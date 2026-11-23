import SwiftUI

struct WorkoutRows: View {
    let workouts: [Workout]
    let unit: UnitLength

    var body: some View {
        ForEach(workouts) { workout in
            NavigationLink(value: workout) {
                WorkoutRow(workout: workout, unit: unit)
            }
        }
    }
}
