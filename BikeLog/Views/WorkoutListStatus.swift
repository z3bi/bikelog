import SwiftUI

struct WorkoutListStatus: View {
    let manager: WorkoutManager

    var body: some View {
        switch manager.refreshState {
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                    .tint(Color.Theme.accentSecondary)
                Text("Loading workouts...")
                    .foregroundStyle(Color.Theme.accentSecondary)
            }
        case .ready:
            ContentUnavailableView("No Workouts", systemImage: "calendar")
                .background(Color.Theme.appBackground)
                .foregroundStyle(Color.Theme.accentSecondary)
        case .failed:
            HStack(spacing: 24) {
                Label("Refresh failed", systemImage: "exclamationmark.triangle")
                Button("Retry", action: manager.retryRefresh)
                    .buttonStyle(.bordered)
            }
            .foregroundStyle(Color.Theme.accentSecondary)
        }
    }
}

#Preview("Loading", traits: .app) {
    let manager = WorkoutManager.preview(.firstLaunch)
    WorkoutListStatus(manager: manager)
        .monitoring(manager)
}

#Preview("Empty", traits: .app) {
    let manager = WorkoutManager.preview(.empty)
    WorkoutListStatus(manager: manager)
        .monitoring(manager)
}

#Preview("Error", traits: .app) {
    let manager = WorkoutManager.preview(.failed)
    WorkoutListStatus(manager: manager)
        .monitoring(manager)
}
