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
        }
    }
}

extension Text {
    func workoutDetailValueStyle() -> some View {
        font(.system(.body, design: .rounded).weight(.semibold).scaled(by: 18.0 / 17.0))
            .foregroundStyle(Color.Theme.darkGreen)
    }
}
