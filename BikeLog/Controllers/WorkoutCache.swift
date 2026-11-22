import Foundation
import OSLog

struct WorkoutCache: Sendable {
    private static let logger = Logger(subsystem: "BikeLog", category: "Workout cache")
    private let directory: URL
    private let legacyDirectory: URL?
    private let queue = DispatchQueue(label: "BikeLog.WorkoutCache", qos: .utility)

    init(directory: URL = URL.cachesDirectory.appending(path: "WorkoutCache", directoryHint: .isDirectory),
         legacyDirectory: URL? = .documentsDirectory) {
        self.directory = directory
        self.legacyDirectory = legacyDirectory
    }

    // Submit from the main actor in query order; perform synchronous file I/O on the serial queue.
    @MainActor
    func load(for activity: Activity) async throws -> HealthResult? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                migrateLegacyCaches()
                continuation.resume(with: Result {
                    guard let data = try readIfPresent(at: file(for: activity)) else { return nil }
                    var snapshot = try JSONDecoder().decode(HealthResult.self, from: data)
                    snapshot.cached = true
                    return snapshot
                })
            }
        }
    }

    @MainActor
    func save(_ snapshot: HealthResult, for activity: Activity) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                continuation.resume(with: Result {
                    try write(JSONEncoder().encode(snapshot), for: activity)
                })
            }
        }
    }

    private func file(for activity: Activity) -> URL {
        directory.appending(path: "\(activity.rawValue).json")
    }

    private func readIfPresent(at url: URL) throws -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch let error as CocoaError where Self.isMissing(error) {
            return nil
        }
    }

    private func write(_ data: Data, for activity: Activity) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: file(for: activity), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    private func migrateLegacyCaches() {
        guard let legacyDirectory else { return }
        for activity in Activity.allCases {
            var legacyFile = legacyDirectory.appending(path: activity.rawValue)
            do {
                let values = try legacyFile.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
                guard values.isRegularFile == true, values.isSymbolicLink != true,
                      let data = try readIfPresent(at: legacyFile) else { continue }
                _ = try JSONDecoder().decode(HealthResult.self, from: data)
                var backup = URLResourceValues()
                backup.isExcludedFromBackup = true
                try legacyFile.setResourceValues(backup)
                if try readIfPresent(at: file(for: activity)) == nil {
                    try write(data, for: activity)
                }
                try FileManager.default.removeItem(at: legacyFile)
            } catch let error as CocoaError where Self.isMissing(error) {
                continue
            } catch {
                Self.logger.error("Could not migrate the \(activity.rawValue) cache: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

    private static func isMissing(_ error: CocoaError) -> Bool {
        error.code == .fileNoSuchFile || error.code == .fileReadNoSuchFile
    }
}
