import XCTest

import Foundation
import PromiseKit

import CtrlpanelCore

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
        var core: CtrlpanelCore!

        // Yes, this is hardcoded to my machine 🙈
        let handle = "0496-6N86Z8-EK12AY-24S415-5BC4"
        let masterPassword = "flunky 0 jumper sop waste"
        let secretKey = "8QZ8-EVHSKT-CE0CB9-CKJCEH-1KH0"

        let accountID = UUID()
        let accountData = CtrlpanelAccount(handle: "Test", hostname: "example.com", password: "secret")

        expectation(description: "everything") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: URL(string: "http://localhost:1834")!, syncToken: nil).done { core = $0 }
            }.done { _ in
                XCTAssertEqual(core.locked, true)
                XCTAssertEqual(core.hasAccount, false)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertEqual(core.onUpdate.fireCount, 1)
            }.then { _ in
                core.createAccount(id: accountID, data: accountData)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertEqual(core.parsedEntries!.accounts[accountID], accountData)
                XCTAssertEqual(core.onUpdate.fireCount, 2)
            }.then { _ in
                core.deleteAccount(id: accountID)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertEqual(core.parsedEntries!.accounts[accountID], nil)
                XCTAssertEqual(core.onUpdate.fireCount, 3)
            }.then { _ in
                core.lock()
            }.done { _ in
                XCTAssertEqual(core.locked, true)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertNil(core.parsedEntries)
                XCTAssertEqual(core.onUpdate.fireCount, 4)
            }.then { _ in
                core.unlock(masterPassword: masterPassword)
            }.done { _ in
                XCTAssertEqual(core.locked, false)
                XCTAssertEqual(core.hasAccount, true)
                XCTAssertNotNil(core.parsedEntries)
                XCTAssertEqual(core.onUpdate.fireCount, 5)
            }
        }

        self.waitForExpectations(timeout: 10)
    }

    func testRandomAccountPassword() {
        var core: CtrlpanelCore!

        expectation(description: "randomAccountPassword") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: URL(string: "http://localhost:1834")!, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.randomAccountPassword()
            }.done { password in
                XCTAssertEqual(password.count, 15)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }
        }

        self.waitForExpectations(timeout: 10)
    }
}
