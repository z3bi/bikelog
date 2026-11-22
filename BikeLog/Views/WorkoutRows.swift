import SwiftUI

struct WorkoutRows: View {
    let workouts: [Workout]

    var body: some View {
        ForEach(workouts) { workout in
            NavigationLink(value: workout) {
                WorkoutRow(workout: workout)
            }
        }
    }
}
