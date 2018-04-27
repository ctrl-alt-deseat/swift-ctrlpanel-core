import XCTest

import Foundation
import PromiseKit

import CtrlpanelCore

// Yes, this is hardcoded to my machine 🙈
let apiHost = URL(string: "http://localhost:1834")!
let deseatmeApiHost = URL(string: "http://localhost:1835")!
let handle = "0496-6N86Z8-EK12AY-24S415-5BC4"
let masterPassword = "flunky 0 jumper sop waste"
let secretKey = "8QZ8-EVHSKT-CE0CB9-CKJCEH-1KH0"

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

        let accountID = UUID()
        let accountData = CtrlpanelAccount(handle: "Test", hostname: "example.com", password: "secret")

        expectation(description: "everything") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
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

    func testHandle() {
        var core: CtrlpanelCore!

        expectation(description: "handle") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.done { _ in
                XCTAssertEqual(core.handle, nil)
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.handle, handle)
            }.then { _ in
                core.lock()
            }.done { _ in
                XCTAssertEqual(core.handle, handle)
            }.then { _ in
                core.unlock(masterPassword: masterPassword)
            }.done { _ in
                XCTAssertEqual(core.handle, handle)
            }
        }

        self.waitForExpectations(timeout: 10)
    }

    func testSecretKey() {
        var core: CtrlpanelCore!

        expectation(description: "secretKey") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.done { _ in
                XCTAssertEqual(core.secretKey, nil)
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.secretKey, secretKey)
            }.then { _ in
                core.lock()
            }.done { _ in
                XCTAssertEqual(core.secretKey, secretKey)
            }.then { _ in
                core.unlock(masterPassword: masterPassword)
            }.done { _ in
                XCTAssertEqual(core.secretKey, secretKey)
            }
        }

        self.waitForExpectations(timeout: 10)
    }

    func testRandomAccountPassword() {
        var core: CtrlpanelCore!

        expectation(description: "randomAccountPassword") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.randomAccountPassword()
            }.done { password in
                XCTAssertEqual(password.count, 15)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }
        }

        self.waitForExpectations(timeout: 10)
    }

    func testAccountsForHostname() {
        var core: CtrlpanelCore!

        let account0ID = UUID()
        let account0Data = CtrlpanelAccount(handle: "A", hostname: "example.com", password: "x")

        let account1ID = UUID()
        let account1Data = CtrlpanelAccount(handle: "C", hostname: "login.example.com", password: "x")

        let account2ID = UUID()
        let account2Data = CtrlpanelAccount(handle: "B", hostname: "example.net", password: "x")

        expectation(description: "accountsForHostname") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.then { _ in
                core.createAccount(id: account0ID, data: account0Data)
            }.then { _ in
                core.createAccount(id: account1ID, data: account1Data)
            }.then { _ in
                core.createAccount(id: account2ID, data: account2Data)
            }.then { _ in
                core.accountsForHostname("example.com")
            }.done { list in
                XCTAssertEqual(list[0].id, account0ID)
                XCTAssertEqual(list[0].score, 1.0)
                XCTAssertEqual(list[0].account, account0Data)

                XCTAssertEqual(list[1].id, account1ID)
                XCTAssertEqual(list[1].score, 0.8)
                XCTAssertEqual(list[1].account, account1Data)

                XCTAssertEqual(list[2].id, account2ID)
                XCTAssertEqual(list[2].score, 0.4)
                XCTAssertEqual(list[2].account, account2Data)
            }.ensure {
                let _ = core.deleteAccount(id: account0ID)
            }.ensure {
                let _ = core.deleteAccount(id: account1ID)
            }.ensure {
                let _ = core.deleteAccount(id: account2ID)
            }
        }

        self.waitForExpectations(timeout: 10)
    }

    func testAccountsForHostnameCodable() throws {
        let account = CtrlpanelAccount(handle: "a", hostname: "example.com", password: "b")
        let match = CtrlpanelAccountMatch(id: UUID(), score: 0.5, account: account)

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        let encoded = try encoder.encode(match)
        let decoded = try decoder.decode(CtrlpanelAccountMatch.self, from: encoded)

        XCTAssertEqual(match, decoded)
    }

    func testInboxEntries() {
        var core: CtrlpanelCore!

        let inboxEntryID = UUID()
        let inboxEntryData = CtrlpanelInboxEntry(hostname: "example.com", email: "linus@example.com")

        expectation(description: "inboxEntries") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.done { _ in
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.onUpdate.fireCount, 1)
            }.then { _ in
                core.createInboxEntry(id: inboxEntryID, data: inboxEntryData)
            }.done { _ in
                XCTAssertEqual(core.parsedEntries!.inbox[inboxEntryID], inboxEntryData)
                XCTAssertEqual(core.onUpdate.fireCount, 2)
            }.then { _ in
                core.deleteInboxEntry(id: inboxEntryID)
            }.done { _ in
                XCTAssertEqual(core.parsedEntries!.inbox[inboxEntryID], nil)
                XCTAssertEqual(core.onUpdate.fireCount, 3)
            }
        }

        self.waitForExpectations(timeout: 10)
    }
}
