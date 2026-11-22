import SwiftUI

struct WorkoutSummaryRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let title: String
    let distance: String
    let count: String
    var isAllTimeHeader = false
    var textScale = 1.0

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout())

        layout {
            Text(title)
                .textCase(isAllTimeHeader ? nil : .uppercase)
                .font(.headline.scaled(by: textScale))
                .foregroundStyle(isAllTimeHeader ? Color.Theme.red : Color.Theme.darkGreen)
            Text(distance)
                .font(.title2.scaled(by: textScale).bold())
                .foregroundStyle(Color.Theme.teal)
            Text(count)
                .font(.callout.scaled(by: textScale).weight(.medium))
                .foregroundStyle(Color.Theme.gray)
        }
        .accessibilityElement(children: .combine)
    }
}
