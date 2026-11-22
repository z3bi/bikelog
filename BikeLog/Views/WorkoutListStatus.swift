import SwiftUI

struct WorkoutListStatus: View {
    let manager: WorkoutManager

    var body: some View {
        switch manager.refreshState {
        case .loading:
            ProgressView("Loading workouts...")
        case .ready:
            ContentUnavailableView("No Workouts", systemImage: "calendar")
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                Label("Couldn't refresh workouts", systemImage: "exclamationmark.circle")
                Button("Retry", action: manager.retryRefresh)
                    .buttonStyle(.bordered)
            }
        }
    }
}
