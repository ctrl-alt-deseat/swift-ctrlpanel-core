import Foundation

public struct CtrlpanelAccount: Codable, Equatable {
    public let handle: String
    public let hostname: String
    public let password: String
    public let otpauth: URL?

    public init (handle: String, hostname: String, password: String, otpauth: URL? = nil) {
        self.handle = handle
        self.hostname = hostname
        self.password = password
        self.otpauth = otpauth
    }

    static public func ==(lhs: CtrlpanelAccount, rhs: CtrlpanelAccount) -> Bool {
        return lhs.handle == rhs.handle && lhs.hostname == rhs.hostname && lhs.password == rhs.password && lhs.otpauth == rhs.otpauth
    }
}

public struct CtrlpanelInboxEntry: Codable, Equatable {
    public let hostname: String
    public let email: String

    public init (hostname: String, email: String) {
        self.hostname = hostname
        self.email = email
    }

    public static func ==(lhs: CtrlpanelInboxEntry, rhs: CtrlpanelInboxEntry) -> Bool {
        return lhs.hostname == rhs.hostname && lhs.email == rhs.email
    }
}

public struct CtrlpanelParsedEntries: Codable {
    public let accounts: [UUID: CtrlpanelAccount]
    public let inbox: [UUID: CtrlpanelInboxEntry]
}

public struct CtrlpanelAccountMatch: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id, score
    }

    public let id: UUID
    public let score: Double
    public let account: CtrlpanelAccount

    public init(id: UUID, score: Double, account: CtrlpanelAccount) {
        self.id = id
        self.score = score
        self.account = account
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(UUID.self, forKey: .id)
        score = try values.decode(Double.self, forKey: .score)
        account = try CtrlpanelAccount(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(score, forKey: .score)
        try account.encode(to: encoder)
    }

    public static func ==(lhs: CtrlpanelAccountMatch, rhs: CtrlpanelAccountMatch) -> Bool {
        return lhs.id == rhs.id && lhs.score == rhs.score && lhs.account == rhs.account
    }
}

public enum CtrlpanelPaymentInformation {
    case apple(transactionIdentifier: String)
    case stripe(email: String, plan: String, token: String)
}

extension CtrlpanelPaymentInformation: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case transactionIdentifier
        case email, plan, token
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .apple(let transactionIdentifier):
            try container.encode("apple", forKey: .type)
            try container.encode(transactionIdentifier, forKey: .transactionIdentifier)
        case .stripe(let email, let plan, let token):
            try container.encode("stripe", forKey: .type)
            try container.encode(email, forKey: .email)
            try container.encode(plan, forKey: .plan)
            try container.encode(token, forKey: .token)
        }
    }
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
    case locked(handle: String, saveDevice: Bool, secretKey: String, syncToken: String)
    case unlocked(handle: String, parsedEntries: CtrlpanelParsedEntries, saveDevice: Bool, secretKey: String, syncToken: String)
    case connected(handle: String, parsedEntries: CtrlpanelParsedEntries, hasPaymentInformation: Bool, saveDevice: Bool, secretKey: String, subscriptionStatus: SubscriptionStatus, syncToken: String, trialDaysLeft: Int)
}

extension CtrlpanelState: Decodable {
    private enum CodingKeys: String, CodingKey {
        case kind
        case handle, parsedEntries, hasPaymentInformation, saveDevice, secretKey, subscriptionStatus, syncToken, trialDaysLeft
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
            let syncToken = try values.decode(String.self, forKey: .syncToken)
            self = .locked(handle: handle, saveDevice: saveDevice, secretKey: secretKey, syncToken: syncToken)
        case "unlocked":
            let handle = try values.decode(String.self, forKey: .handle)
            let parsedEntries = try values.decode(CtrlpanelParsedEntries.self, forKey: .parsedEntries)
            let saveDevice = try values.decode(Bool.self, forKey: .saveDevice)
            let secretKey = try values.decode(String.self, forKey: .secretKey)
            let syncToken = try values.decode(String.self, forKey: .syncToken)
            self = .unlocked(handle: handle, parsedEntries: parsedEntries, saveDevice: saveDevice, secretKey: secretKey, syncToken: syncToken)
        case "connected":
            let handle = try values.decode(String.self, forKey: .handle)
            let parsedEntries = try values.decode(CtrlpanelParsedEntries.self, forKey: .parsedEntries)
            let hasPaymentInformation = try values.decode(Bool.self, forKey: .hasPaymentInformation)
            let saveDevice = try values.decode(Bool.self, forKey: .saveDevice)
            let secretKey = try values.decode(String.self, forKey: .secretKey)
            let subscriptionStatus = try values.decode(SubscriptionStatus.self, forKey: .subscriptionStatus)
            let syncToken = try values.decode(String.self, forKey: .syncToken)
            let trialDaysLeft = try values.decode(Int.self, forKey: .trialDaysLeft)
            self = .connected(handle: handle, parsedEntries: parsedEntries, hasPaymentInformation: hasPaymentInformation, saveDevice: saveDevice, secretKey: secretKey, subscriptionStatus: subscriptionStatus, syncToken: syncToken, trialDaysLeft: trialDaysLeft)
        default:
            throw CodingError.unknownKind(kind)
        }
    }
}
