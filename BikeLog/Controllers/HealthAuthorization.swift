import Foundation

/// Runs the authorization request at most once at a time and shares the result with every caller.
/// A failed request is cleared so a later call can try again.
actor HealthAuthorization {
    private let request: @Sendable () async throws -> Void
    private var pending: Task<Void, Error>?

    init(request: @escaping @Sendable () async throws -> Void) {
        self.request = request
    }

    func authorize() async throws {
        let task = pending ?? Task { try await request() }
        pending = task
        do {
            try await task.value
        } catch {
            if pending == task { pending = nil }
            throw error
        }
    }
}
