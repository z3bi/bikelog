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
