import Foundation

import JSBridge
import PromiseKit
import Signals

@available(macOS 10.13, *)
open class CtrlpanelCore {
    internal let bridge: JSBridge
    internal var state: CtrlpanelState

    public let onUpdate = Signal<Void>()

    public var handle: String? {
        switch state {
            case .empty: return nil
            case .locked(let handle, _, _, _): return handle
            case .unlocked(let handle, _, _, _, _): return handle
            case .connected(let handle, _, _, _, _, _, _, _): return handle
        }
    }

    public var secretKey: String? {
        switch state {
            case .empty: return nil
            case .locked(_, _, let secretKey, _): return secretKey
            case .unlocked(_, _, _, let secretKey, _): return secretKey
            case .connected(_, _, _, _, let secretKey, _, _, _): return secretKey
        }
    }

    public var syncToken: String? {
        switch state {
            case .empty: return nil
            case .locked(_, _, _, let syncToken): return syncToken
            case .unlocked(_, _, _, _, let syncToken): return syncToken
            case .connected(_, _, _, _, _, _, let syncToken, _): return syncToken
        }
    }

    public var hasAccount: Bool {
        switch state {
            case .empty: return false
            case .locked(_, _, _, _): return true
            case .unlocked(_, _, _, _, _): return true
            case .connected(_, _, _, _, _, _, _, _): return true
        }
    }

    public var locked: Bool {
        switch state {
            case .empty: return true
            case .locked(_, _, _, _): return true
            case .unlocked(_, _, _, _, _): return false
            case .connected(_, _, _, _, _, _, _, _): return false
        }
    }

    public var parsedEntries: CtrlpanelParsedEntries? {
        switch state {
            case .empty: return nil
            case .locked(_, _, _, _): return nil
            case .unlocked(_, let result, _, _, _): return result
            case .connected(_, let result, _, _, _, _, _, _): return result
        }
    }

    public static func asyncInit(apiHost: URL?, deseatmeApiHost: URL?, syncToken: String?) -> Promise<CtrlpanelCore> {
        let bridge = JSBridge(libraryCode: libraryCode)

        return firstly {
            bridge.call(function: "Ctrlpanel.boot", withArgs: (apiHost, deseatmeApiHost))
        }.then { _ in
            bridge.call(function: "Ctrlpanel.init", withArg: syncToken)
        }.then { state in
            return Promise.value(CtrlpanelCore(bridge: bridge, state: state))
        }
    }

    internal init(bridge: JSBridge, state: CtrlpanelState) {
        self.bridge = bridge
        self.state = state
    }

    internal func updateState(_ fn: @escaping () -> Promise<CtrlpanelState>) -> Promise<Void> {
        return fn().done {
            self.state = $0
            self.onUpdate.fire(())
        }
    }

    public func randomAccountPassword() -> Promise<String> {
        return self.bridge.call(function: "Ctrlpanel.randomAccountPassword")
    }

    public func randomHandle() -> Promise<String> {
        return self.bridge.call(function: "Ctrlpanel.randomHandle")
    }

    public func randomMasterPassword() -> Promise<String> {
        return self.bridge.call(function: "Ctrlpanel.randomMasterPassword")
    }

    public func randomSecretKey() -> Promise<String> {
        return self.bridge.call(function: "Ctrlpanel.randomSecretKey")
    }

    public func lock() -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.lock")
        }
    }

    public func reset(withSyncToken syncToken: String) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.init", withArg: syncToken)
        }
    }

    public func signup(handle: String, secretKey: String, masterPassword: String, saveDevice: Bool) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.signup", withArgs: (handle, secretKey, masterPassword, saveDevice))
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

    public func accountsForHostname(_ hostname: String) -> Promise<[CtrlpanelAccountMatch]> {
        return self.bridge.call(function: "Ctrlpanel.accountsForHostname", withArg: hostname)
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

    public func createInboxEntry (id: UUID, data: CtrlpanelInboxEntry) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.createInboxEntry", withArgs: (id, data))
        }
    }

    public func deleteInboxEntry (id: UUID) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.deleteInboxEntry", withArg: id)
        }
    }

    public func importFromDeseatme (exportToken: String) -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.importFromDeseatme", withArg: exportToken)
        }
    }

    public func clearStoredData () -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.clearStoredData")
        }
    }

    public func deleteUser () -> Promise<Void> {
        return updateState {
            self.bridge.call(function: "Ctrlpanel.deleteUser")
        }
    }
}
