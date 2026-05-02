import Foundation

enum Feature {
    case cleanSafe
    case cleanCaution
    case batchClean
    case developerClean
}

enum FeatureGate {
    @MainActor
    static func isEnabled(_ feature: Feature) -> Bool {
        switch feature {
        case .cleanSafe:
            return true
        case .cleanCaution, .batchClean, .developerClean:
            return LicenseService.shared.isProUnlocked
        }
    }
}
