import Foundation

struct SpeedSplit: Identifiable, Sendable {
    struct DistanceSample: Sendable {
        let start: Date
        let end: Date
        let meters: Double
    }

    let index: Int
    let length: Measurement<UnitLength>
    let elapsed: TimeInterval

    var id: Int { index }

    func speed(in unit: UnitSpeed) -> Measurement<UnitSpeed> {
        (length / Measurement(value: elapsed, unit: .seconds)).converted(to: unit)
    }

    static func calculate(samples: [DistanceSample], splitLength: Measurement<UnitLength>,
                          workoutStart: Date, workoutEnd: Date) -> [Self] {
        let splitMeters = splitLength.converted(to: .meters).value
        let movingSamples = samples.filter { $0.meters > 0 }.sorted { $0.start < $1.start }
        // A lone or coarser-than-split total is not a usable speed timeline.
        guard movingSamples.count > 1 else { return [] }

        var covered = 0.0
        var previousSampleEnd = workoutStart
        var previousCrossing = workoutStart
        var splits: [Self] = []

        for sample in movingSamples {
            guard sample.meters <= splitMeters + 1e-6,
                  sample.start >= previousSampleEnd, sample.end > sample.start, sample.end <= workoutEnd else {
                return []
            }
            let sampleEndDistance = covered + sample.meters
            let index = splits.count + 1
            let boundary = Double(index) * splitMeters
            if sampleEndDistance + 1e-6 >= boundary {
                let fraction = min(1, (boundary - covered) / sample.meters)
                let crossing = sample.start + fraction * sample.end.timeIntervalSince(sample.start)
                let elapsed = crossing.timeIntervalSince(previousCrossing)
                guard elapsed > 0 else { return [] }
                splits.append(Self(index: index, length: splitLength, elapsed: elapsed))
                previousCrossing = crossing
            }
            covered = sampleEndDistance
            previousSampleEnd = sample.end
        }
        return splits
    }
}
