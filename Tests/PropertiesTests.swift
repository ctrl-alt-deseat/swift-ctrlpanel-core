import XCTest

import Foundation
import PromiseKit

import CtrlpanelCore

// Yes, this is hardcoded to my machine 🙈
fileprivate let apiHost = URL(string: "http://localhost:1834")!
fileprivate let deseatmeApiHost = URL(string: "http://localhost:1835")!
fileprivate let handle = "0496-6N86Z8-EK12AY-24S415-5BC4"
fileprivate let masterPassword = "flunky 0 jumper sop waste"
fileprivate let secretKey = "8QZ8-EVHSKT-CE0CB9-CKJCEH-1KH0"
fileprivate let syncToken = "04966N86Z8EK12AY24S4155BC48QZ8EVHSKTCE0CB9CKJCEH1KH0"

@available(macOS 10.13, *)
class PropertiesTests: XCTestCase {
    func testHandle() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "handle") {
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
    }

    func testSecretKey() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "secretKey") {
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
    }

    func testSyncToken() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "syncToken") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.done { _ in
                XCTAssertEqual(core.syncToken, nil)
            }.then { _ in
                core.login(handle: handle, secretKey: secretKey, masterPassword: masterPassword, saveDevice: false)
            }.done { _ in
                XCTAssertEqual(core.syncToken, syncToken)
            }.then { _ in
                core.lock()
            }.done { _ in
                XCTAssertEqual(core.syncToken, syncToken)
            }.then { _ in
                core.unlock(masterPassword: masterPassword)
            }.done { _ in
                XCTAssertEqual(core.syncToken, syncToken)
            }
        }
    }
}
