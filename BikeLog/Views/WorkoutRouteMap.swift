import MapKit
import SwiftUI

struct WorkoutRouteMap: View {
    let segments: [[CLLocationCoordinate2D]]

    var body: some View {
        Map(initialPosition: .automatic) {
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
        .navigationTitle("Route")
        .toolbarTitleDisplayMode(.inline)
    }
}
