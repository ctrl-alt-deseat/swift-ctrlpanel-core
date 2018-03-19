import Foundation

import JSBridge
import PromiseKit

@available(macOS 10.13, *)
open class CtrlpanelCore {
    internal let bridge: JSBridge
    internal var state: CtrlpanelState

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

    public static func asyncInit(apiHost: URL?, syncToken: String?) -> Promise<CtrlpanelCore> {
        let bridge = JSBridge(libraryCode: libraryCode)

        return firstly { () -> Promise<Void> in
            if let host = apiHost {
                return bridge.call(function: "Ctrlpanel.boot", withArg: host)
            } else {
                return bridge.call(function: "Ctrlpanel.boot")
            }
        }.then { _ -> Promise<CtrlpanelState> in
            if let token = syncToken {
                return bridge.call(function: "Ctrlpanel.init", withArg: token)
            } else {
                return bridge.call(function: "Ctrlpanel.init")
            }
        }.then { state in
            return Promise.value(CtrlpanelCore(bridge: bridge, state: state))
        }
    }

    internal init(bridge: JSBridge, state: CtrlpanelState) {
        self.bridge = bridge
        self.state = state
    }

    internal func updateState(_ fn: @escaping () -> Promise<CtrlpanelState>) -> Promise<Void> {
        return fn().done { self.state = $0 }
    }

    public func lock() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.lock")
        }
    }

    public func login(handle: String, secretKey: String, masterPassword: String, saveDevice: Bool) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.login", withArgs: (handle, secretKey, masterPassword, saveDevice))
        }
    }

    public func unlock(masterPassword: String) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.unlock", withArg: masterPassword)
        }
    }

    public func connect() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.connect")
        }
    }

    public func sync() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.sync")
        }
    }

    public func createAccount (id: UUID, data: CtrlpanelAccount) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.createAccount", withArgs: (id, data))
        }
    }

    public func deleteAccount (id: UUID) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.deleteAccount", withArg: id)
        }
    }

    public func updateAccount (id: UUID, data: CtrlpanelAccount) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.updateAccount", withArgs: (id, data))
        }
    }

    public func clearStoredData () -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.clearStoredData")
        }
    }
}
