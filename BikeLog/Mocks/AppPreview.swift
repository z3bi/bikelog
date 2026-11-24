import SwiftUI

/// Applies the app root's appearance (navigation bar colors and dark mode) to a preview.
struct AppPreview: PreviewModifier {
    static func makeSharedContext() async throws {
        await MainActor.run { AppAppearance.configure() }
    }

    func body(content: Content, context: Void) -> some View {
        content.appColorScheme()
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var app: Self { .modifier(AppPreview()) }
}

extension View {
    /// Starts the manager's workout monitoring, for previews of screens that don't start it themselves.
    func monitoring(_ manager: WorkoutManager) -> some View {
        task { await manager.monitorWorkouts() }
    }
}
