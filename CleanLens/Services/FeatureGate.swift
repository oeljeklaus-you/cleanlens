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
        if AppConfig.isPublicBeta {
            switch feature {
            case .cleanSafe, .cleanCaution, .batchClean, .developerClean:
                return true
            }
        }

        switch feature {
        case .cleanSafe:
            return true
        case .cleanCaution, .batchClean, .developerClean:
            return LicenseService.shared.isProUnlocked
        }
    }
}
