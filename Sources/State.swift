import Foundation

public struct CtrlpanelAccount: Codable, Equatable {
    public let handle: String
    public let hostname: String
    public let password: String

    public init (handle: String, hostname: String, password: String) {
        self.handle = handle
        self.hostname = hostname
        self.password = password
    }
}

public func ==(lhs: CtrlpanelAccount, rhs: CtrlpanelAccount) -> Bool {
    return (
        lhs.handle == rhs.handle &&
        lhs.hostname == rhs.hostname &&
        lhs.password == rhs.password
    )
}

public struct CtrlpanelInboxEntry: Codable, Equatable {
    public let hostname: String
    public let email: String

    public init (hostname: String, email: String) {
        self.hostname = hostname
        self.email = email
    }
}

public func ==(lhs: CtrlpanelInboxEntry, rhs: CtrlpanelInboxEntry) -> Bool {
    return (
        lhs.hostname == rhs.hostname &&
        lhs.email == rhs.email
    )
}

public struct CtrlpanelParsedEntries: Codable {
    public let accounts: [UUID: CtrlpanelAccount]
    public let inbox: [UUID: CtrlpanelInboxEntry]
}

enum SubscriptionStatus: String, Codable {
    case trialing = "trialing"
    case active = "active"
    case pastDue = "past_due"
    case canceled = "canceled"
    case unpaid = "unpaid"
}

enum CtrlpanelState {
    case empty()
    case locked(handle: String, saveDevice: Bool, secretKey: String)
    case unlocked(handle: String, parsedEntries: CtrlpanelParsedEntries, saveDevice: Bool, secretKey: String)
    case connected(handle: String, parsedEntries: CtrlpanelParsedEntries, hasPaymentInformation: Bool, saveDevice: Bool, secretKey: String, subscriptionStatus: SubscriptionStatus, trialDaysLeft: Int)
}

extension CtrlpanelState: Decodable {
    private enum CodingKeys: String, CodingKey {
        case kind
        case handle, parsedEntries, hasPaymentInformation, saveDevice, secretKey, subscriptionStatus, trialDaysLeft
    }

    public enum CodingError: Swift.Error {
        case unknownKind(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try values.decode(String.self, forKey: .kind)

        switch kind {
        case "empty":
            self = .empty()
        case "locked":
            let handle = try values.decode(String.self, forKey: .handle)
            let saveDevice = try values.decode(Bool.self, forKey: .saveDevice)
            let secretKey = try values.decode(String.self, forKey: .secretKey)
            self = .locked(handle: handle, saveDevice: saveDevice, secretKey: secretKey)
        case "unlocked":
            let handle = try values.decode(String.self, forKey: .handle)
            let parsedEntries = try values.decode(CtrlpanelParsedEntries.self, forKey: .parsedEntries)
            let saveDevice = try values.decode(Bool.self, forKey: .saveDevice)
            let secretKey = try values.decode(String.self, forKey: .secretKey)
            self = .unlocked(handle: handle, parsedEntries: parsedEntries, saveDevice: saveDevice, secretKey: secretKey)
        case "connected":
            let handle = try values.decode(String.self, forKey: .handle)
            let parsedEntries = try values.decode(CtrlpanelParsedEntries.self, forKey: .parsedEntries)
            let hasPaymentInformation = try values.decode(Bool.self, forKey: .hasPaymentInformation)
            let saveDevice = try values.decode(Bool.self, forKey: .saveDevice)
            let secretKey = try values.decode(String.self, forKey: .secretKey)
            let subscriptionStatus = try values.decode(SubscriptionStatus.self, forKey: .subscriptionStatus)
            let trialDaysLeft = try values.decode(Int.self, forKey: .trialDaysLeft)
            self = .connected(handle: handle, parsedEntries: parsedEntries, hasPaymentInformation: hasPaymentInformation, saveDevice: saveDevice, secretKey: secretKey, subscriptionStatus: subscriptionStatus, trialDaysLeft: trialDaysLeft)
        default:
            throw CodingError.unknownKind(kind)
        }
    }
}
