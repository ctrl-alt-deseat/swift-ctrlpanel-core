import XCTest

import PromiseKit

extension XCTestCase {
    func expectation(description: String, _ promiseFactory: () -> Promise<Void>) {
        let done = self.expectation(description: "Promise \(description) settled")

        firstly {
            promiseFactory()
        }.catch { err in
            XCTFail("Failed with error: \(err)")
        }.finally {
            done.fulfill()
        }
    }

    func waitedExpectation(description: String, timeout: TimeInterval = 10, _ promiseFactory: () -> Promise<Void>) {
        expectation(description: description, promiseFactory)
        waitForExpectations(timeout: timeout)
    }
}
