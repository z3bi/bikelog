import MapKit
import SwiftUI

struct WorkoutRouteMap: View {
    let segments: [[CLLocationCoordinate2D]]
    @State private var isExpanded = false

    var body: some View {
        map(interactionModes: [])
            .listRowBackground(Color.Theme.appBackground)
            .frame(height: 200)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .overlay {
                Button {
                    isExpanded = true
                } label: {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Expand route map")
            }
            .sheet(isPresented: $isExpanded) {
                NavigationStack {
                    map(interactionModes: .all)
                        .navigationTitle("Route")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { isExpanded = false }
                            }
                        }
                }
            }
    }

    private func map(interactionModes: MapInteractionModes) -> some View {
        Map(initialPosition: .automatic, interactionModes: interactionModes) {
            ForEach(segments.indices, id: \.self) { index in
                MapPolyline(coordinates: segments[index])
                    .stroke(Color._Theme.teal, lineWidth: 4)
            }
            if let start = segments.first?.first {
                Marker("Start", systemImage: "flag", coordinate: start)
                    .tint(Color._Theme.teal)
            }
            if let finish = segments.last?.last {
                Marker("Finish", systemImage: "flag.checkered", coordinate: finish)
                    .tint(Color._Theme.orange)
            }
        }
    }
}
