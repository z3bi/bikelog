import Foundation
import OSLog

struct WorkoutCache: Sendable {
    private let directory: URL
    private let legacyDirectory: URL?
    private let queue = DispatchQueue(label: "BikeLog.WorkoutCache", qos: .utility)
    private static let name = "cycling"

    init(directory: URL = URL.cachesDirectory.appending(path: "WorkoutCache", directoryHint: .isDirectory),
         legacyDirectory: URL? = .documentsDirectory) {
        self.directory = directory
        self.legacyDirectory = legacyDirectory
    }

    // Synchronous file I/O runs on a serial queue; each snapshot is complete, so late writes are harmless.
    func load() async throws -> HealthResult? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                migrateLegacyCaches()
                continuation.resume(with: Result {
                    guard let data = try readIfPresent(at: file) else { return nil }
                    var snapshot = try JSONDecoder().decode(HealthResult.self, from: data)
                    snapshot.cached = true
                    return snapshot
                })
            }
        }
    }

    func save(_ snapshot: HealthResult) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                continuation.resume(with: Result {
                    try write(JSONEncoder().encode(snapshot))
                })
            }
        }
    }

    private var file: URL {
        directory.appending(path: "\(Self.name).json")
    }

    private func readIfPresent(at url: URL) throws -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch let error as CocoaError where Self.isMissing(error) {
            return nil
        }
    }

    private func write(_ data: Data) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: file, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    private func migrateLegacyCaches() {
        guard let legacyDirectory else { return }
        var legacyFile = legacyDirectory.appending(path: Self.name)
        do {
            let values = try legacyFile.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
            guard values.isRegularFile == true, values.isSymbolicLink != true,
                  let data = try readIfPresent(at: legacyFile) else { return }
            _ = try JSONDecoder().decode(HealthResult.self, from: data)
            var backup = URLResourceValues()
            backup.isExcludedFromBackup = true
            try legacyFile.setResourceValues(backup)
            if try readIfPresent(at: file) == nil {
                try write(data)
            }
            try FileManager.default.removeItem(at: legacyFile)
        } catch let error as CocoaError where Self.isMissing(error) {
            return
        } catch {
            Logger.workoutCache.error("Could not migrate the legacy cache: \(error.localizedDescription, privacy: .private)")
        }
    }

    private static func isMissing(_ error: CocoaError) -> Bool {
        error.code == .fileNoSuchFile || error.code == .fileReadNoSuchFile
    }
}
