import XCTest

import Foundation
import PromiseKit

import CtrlpanelCore

// Yes, this is hardcoded to my machine 🙈
fileprivate let apiHost = URL(string: "http://localhost:1834")!
fileprivate let deseatmeApiHost = URL(string: "http://localhost:1835")!

@available(macOS 10.13, *)
class RandomValuesTests: XCTestCase {
    func testRandomAccountPassword() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "randomAccountPassword") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.randomAccountPassword()
            }.done { password in
                XCTAssertEqual(password.count, 15)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }
        }
    }

    func testRandomHandle() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "randomHandle") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.randomHandle()
            }.done { handle in
                XCTAssertEqual(handle.count, 30)
                XCTAssertEqual(handle.components(separatedBy: "-").count, 5)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }
        }
    }

    func testRandomMasterPassword() {
        var core: CtrlpanelCore!

        waitedExpectation(description: "randomMasterPassword") {
            firstly {
                CtrlpanelCore.asyncInit(apiHost: apiHost, deseatmeApiHost: deseatmeApiHost, syncToken: nil).done { core = $0 }
            }.then { _ in
                core.randomMasterPassword()
            }.done { password in
                XCTAssertEqual(password.components(separatedBy: " ").count, 5)
                XCTAssertEqual(core.onUpdate.fireCount, 0)
            }
        }
    }
}
