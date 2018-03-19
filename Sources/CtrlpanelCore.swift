import Foundation

import JSBridge
import PromiseKit

@available(macOS 10.13, *)
open class CtrlpanelCore {
    internal let bridge = JSBridge(libraryCode: libraryCode)
    internal var state = CtrlpanelState.empty()
    internal var _ready: Promise<Void>?

    public var ready: Promise<Void> { return self._ready! }

    public var hasAccount: Bool {
        switch state {
            case .empty: return false
            case .locked(_, _, _): return true
            case .unlocked(_, _, _, _): return true
            case .connected(_, _, _, _, _, _, _): return true
        }
    }

    public var locked: Bool {
        switch state {
            case .empty: return true
            case .locked(_, _, _): return true
            case .unlocked(_, _, _, _): return false
            case .connected(_, _, _, _, _, _, _): return false
        }
    }

    public var parsedEntries: CtrlpanelParsedEntries? {
        switch state {
            case .empty: return nil
            case .locked(_, _, _): return nil
            case .unlocked(_, let result, _, _): return result
            case .connected(_, let result, _, _, _, _, _): return result
        }
    }

    public init(apiHost: URL?, syncToken: String?) {
        self._ready = firstly { () -> Promise<Void> in
            if let host = apiHost {
                return self.bridge.call(function: "Ctrlpanel.boot", withArg: host)
            } else {
                return self.bridge.call(function: "Ctrlpanel.boot")
            }
        }.then { _ -> Promise<CtrlpanelState> in
            if let token = syncToken {
                return self.bridge.call(function: "Ctrlpanel.init", withArg: token)
            } else {
                return self.bridge.call(function: "Ctrlpanel.init")
            }
        }.done { state in
            self.state = state
        }
    }

    internal func updateState(_ fn: @escaping () -> Promise<CtrlpanelState>) -> Promise<Void> {
        return ready.then { _ in fn() }.tap {
            if case .fulfilled(let state) = $0 { self.state = state }
        }.asVoid()
    }

    func lock() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.lock")
        }
    }

    func login(handle: String, secretKey: String, masterPassword: String, saveDevice: Bool) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.login", withArgs: (handle, secretKey, masterPassword, saveDevice))
        }
    }

    func unlock(masterPassword: String) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.unlock", withArg: masterPassword)
        }
    }

    func connect() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.connect")
        }
    }

    func sync() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.sync")
        }
    }

    func createAccount (id: UUID, data: CtrlpanelAccount) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.createAccount", withArgs: (id, data))
        }
    }

    func deleteAccount (id: UUID) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.deleteAccount", withArg: id)
        }
    }

    func updateAccount (id: UUID, data: CtrlpanelAccount) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.updateAccount", withArgs: (id, data))
        }
    }

    func clearStoredData () -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.clearStoredData")
        }
    }
}
