import Foundation

struct MileSpeedSplit: Identifiable, Sendable {
    struct DistanceSample: Sendable {
        let start: Date
        let end: Date
        let meters: Double
    }

    static let metersPerMile = Measurement(value: 1, unit: UnitLength.miles).converted(to: .meters).value

    let mile: Int
    let elapsed: TimeInterval

    var id: Int { mile }
    var milesPerHour: Double { 3600 / elapsed }

    static func calculate(samples: [DistanceSample], workoutStart: Date, workoutEnd: Date) -> [Self] {
        let movingSamples = samples.filter { $0.meters > 0 }.sorted { $0.start < $1.start }
        // A lone or coarser-than-mile total is not a usable speed timeline.
        guard movingSamples.count > 1 else { return [] }

        var covered = 0.0
        var previousSampleEnd = workoutStart
        var previousCrossing = workoutStart
        var splits: [Self] = []

        for sample in movingSamples {
            guard sample.meters <= metersPerMile + 1e-6,
                  sample.start >= previousSampleEnd, sample.end > sample.start, sample.end <= workoutEnd else {
                return []
            }
            let sampleEndDistance = covered + sample.meters
            let mile = splits.count + 1
            let boundary = Double(mile) * metersPerMile
            if sampleEndDistance + 1e-6 >= boundary {
                let fraction = min(1, (boundary - covered) / sample.meters)
                let crossing = sample.start + fraction * sample.end.timeIntervalSince(sample.start)
                let elapsed = crossing.timeIntervalSince(previousCrossing)
                guard elapsed > 0 else { return [] }
                splits.append(Self(mile: mile, elapsed: elapsed))
                previousCrossing = crossing
            }
            covered = sampleEndDistance
            previousSampleEnd = sample.end
        }
        return splits
    }
}
