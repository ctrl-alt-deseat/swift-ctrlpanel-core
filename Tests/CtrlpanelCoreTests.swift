import XCTest

import Foundation
import PromiseKit

@testable import CtrlpanelCore

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
}

@available(macOS 10.13, *)
class CtrlpanelCoreTests: XCTestCase {
    // This should absolutely be broken out to multiple tests!
    func testEverythingWorks() {
        let core = CtrlpanelCore(apiHost: URL(string: "http://localhost:1834")!, syncToken: nil)

        // Yes, this is hardcoded to my machine 🙈
        let handle = "0496-6N86Z8-EK12AY-24S415-5BC4"
        let masterPassword = "flunky 0 jumper sop waste"
        let secretKey = "8QZ8-EVHSKT-CE0CB9-CKJCEH-1KH0"

        let accountID = UUID()
        let accountData = CtrlpanelAccount(handle: "Test", hostname: "example.com", password: "secret")

        expectation(description: "everything") {
            firstly {
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
            }.then { _ in
                core.createAccount(id: accountID, data: accountData)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertEqual(core.parsedEntries!.accounts[accountID], accountData)
            }.then { _ in
                core.deleteAccount(id: accountID)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertEqual(core.parsedEntries!.accounts[accountID], nil)
            }.then { _ in
                core.lock()
            }.done { _ in
                XCTAssertEqual(core.locked, true)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertNil(core.parsedEntries)
            }.then { _ in
                core.unlock(masterPassword: masterPassword)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertNotNil(core.parsedEntries)
            }
        }

        self.waitForExpectations(timeout: 10)
    }
}
