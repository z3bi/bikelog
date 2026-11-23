import SwiftUI

struct WorkoutSummaryRow: View {
    let title: String
    let distance: String
    let count: String
    var isAllTimeHeader = false
    var textScale = 1.0

    var body: some View {
        HStack {
            Text(title)
                .textCase(.uppercase)
                .font(.headline.scaled(by: textScale))
                .foregroundStyle(isAllTimeHeader ? Color.Theme.accent : Color.Theme.secondary)
            Text(distance)
                .font(.title2.scaled(by: textScale).bold())
                .foregroundStyle(Color.Theme.primary)
            Text(count)
                .font(.callout.scaled(by: textScale).weight(.medium))
                .foregroundStyle(Color.Theme.accentSecondary)
        }
        .listRowBackground(Color.Theme.appBackground)
    }
}
