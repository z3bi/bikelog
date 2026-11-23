import SwiftUI

struct WorkoutDetailValueRow: View {
    let label: LocalizedStringKey
    let value: String

    init(_ label: LocalizedStringKey, value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        LabeledContent {
            Text(value).workoutDetailValueStyle()
        } label: {
            Text(label)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(Color.Theme.secondary)
        }
        .listRowBackground(Color.Theme.appBackground)
    }
}

extension Text {
    func workoutDetailValueStyle() -> some View {
        font(.system(.body, design: .rounded).weight(.bold))
            .foregroundStyle(Color.Theme.primary)
    }
}
