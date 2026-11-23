import XCTest
@testable import BikeLog

final class HealthAuthorizationTests: XCTestCase {
    func testConcurrentAndLaterCallersShareOneRequest() async throws {
        let requests = RequestCounter()
        let authorization = HealthAuthorization { _ = await requests.next() }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<3 {
                group.addTask { try await authorization.authorize() }
            }
            try await group.waitForAll()
        }
        try await authorization.authorize()

        let count = await requests.count
        XCTAssertEqual(count, 1)
    }

    func testFailedRequestIsRetriedOnNextCall() async throws {
        let requests = RequestCounter()
        let authorization = HealthAuthorization {
            if await requests.next() == 1 { throw CocoaError(.userCancelled) }
        }

        do {
            try await authorization.authorize()
            XCTFail("Expected the first request to fail")
        } catch {}
        try await authorization.authorize()
        try await authorization.authorize()

        let count = await requests.count
        XCTAssertEqual(count, 2)
    }
}

private actor RequestCounter {
    private(set) var count = 0

    func next() -> Int {
        count += 1
        return count
    }
}
