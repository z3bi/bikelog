import SwiftUI

struct WorkoutSummaryRow: View {
    let title: String
    let distance: String
    let count: String
    var isAllTimeHeader = false

    var body: some View {
        HStack {
            Text(title)
                .textCase(.uppercase)
                .font(.headline)
                .foregroundStyle(isAllTimeHeader ? Color.Theme.accent : Color.Theme.secondary)
            Text(distance)
                .font(.title2.bold())
                .foregroundStyle(Color.Theme.primary)
            Text(count)
                .font(.callout.weight(.medium))
                .foregroundStyle(Color.Theme.accentSecondary)
        }
        .listRowBackground(Color.Theme.appBackground)
    }
}

#Preview("Period", traits: .app, .sizeThatFitsLayout) {
    List {
        WorkoutSummaryRow(title: "Nov", distance: "87.7 mi", count: Workout.countDescription(4))
    }
    .themedList()
}

#Preview("All-Time Header", traits: .app, .sizeThatFitsLayout) {
    List {
        WorkoutSummaryRow(title: "Total", distance: "1,241.5 miles", count: Workout.countDescription(55),
                          isAllTimeHeader: true)
    }
    .themedList()
}
