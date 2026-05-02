import Foundation

enum LicenseActivationError: LocalizedError {
    case invalidKey

    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "That license key is not valid."
        }
    }
}

@MainActor
final class LicenseService: ObservableObject {
    static let shared = LicenseService()

    @Published private(set) var isProUnlocked: Bool

    private let userDefaults: UserDefaults
    private let licenseKeyDefaultsKey = "CleanLens.licenseKey"
    private let isProDefaultsKey = "CleanLens.isPro"
    private let testKey = "CLEANLENS_PRO"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let storedKey = userDefaults.string(forKey: licenseKeyDefaultsKey) ?? ""
        self.isProUnlocked = storedKey == testKey

        if isProUnlocked {
            userDefaults.set(true, forKey: isProDefaultsKey)
        } else {
            userDefaults.removeObject(forKey: licenseKeyDefaultsKey)
            userDefaults.removeObject(forKey: isProDefaultsKey)
        }
    }

    func activateLicense(key: String) async throws -> Bool {
        let normalizedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalizedKey == testKey else {
            throw LicenseActivationError.invalidKey
        }

        userDefaults.set(normalizedKey, forKey: licenseKeyDefaultsKey)
        userDefaults.set(true, forKey: isProDefaultsKey)
        isProUnlocked = true
        return true
    }

    func deactivate() {
        userDefaults.removeObject(forKey: licenseKeyDefaultsKey)
        userDefaults.removeObject(forKey: isProDefaultsKey)
        isProUnlocked = false
    }

    func isActivated() -> Bool {
        isProUnlocked
    }
}
