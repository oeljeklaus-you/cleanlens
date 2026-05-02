import Foundation

struct CleaningExplanation {
    let name: String
    let safetyLevel: SafetyLevel
    let what: String
    let why: String
    let impact: String
    let safeToDeleteReason: String
    let confidenceLevel: ConfidenceLevel
    let usedBy: String
    let recoveryNote: String
    let defaultSelected: Bool
}

enum CleaningExplanationLibrary {
    static func explanation(forKnownPath path: String) -> CleaningExplanation {
        let standardizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
        let homePath = FileManager.default.homeDirectoryForCurrentUser.standardizedFileURL.path

        switch standardizedPath {
        case "\(homePath)/Library/Caches":
            return appCaches
        case "\(homePath)/Library/Logs":
            return appLogs
        case "\(homePath)/Library/Developer/Xcode/DerivedData":
            return xcodeDerivedData
        case "\(homePath)/.npm":
            return npmCache
        case "\(homePath)/.cache":
            return userCacheFolder
        default:
            return userCacheFolder
        }
    }

    static func largeDownloadExplanation(fileName: String) -> CleaningExplanation {
        CleaningExplanation(
            name: fileName,
            safetyLevel: .caution,
            what: Copy.Explanation.LargeDownload.what,
            why: Copy.Explanation.LargeDownload.why,
            impact: Copy.Explanation.LargeDownload.impact,
            safeToDeleteReason: Copy.Explanation.LargeDownload.safeReason,
            confidenceLevel: .medium,
            usedBy: Copy.Explanation.LargeDownload.usedBy,
            recoveryNote: Copy.Explanation.LargeDownload.recovery,
            defaultSelected: false
        )
    }

    private static let appCaches = CleaningExplanation(
        name: Copy.Explanation.AppCaches.name,
        safetyLevel: .safe,
        what: Copy.Explanation.AppCaches.what,
        why: Copy.Explanation.AppCaches.why,
        impact: Copy.Explanation.AppCaches.impact,
        safeToDeleteReason: Copy.Explanation.AppCaches.safeReason,
        confidenceLevel: .high,
        usedBy: Copy.Explanation.AppCaches.usedBy,
        recoveryNote: Copy.Explanation.AppCaches.recovery,
        defaultSelected: true
    )

    private static let appLogs = CleaningExplanation(
        name: Copy.Explanation.AppLogs.name,
        safetyLevel: .safe,
        what: Copy.Explanation.AppLogs.what,
        why: Copy.Explanation.AppLogs.why,
        impact: Copy.Explanation.AppLogs.impact,
        safeToDeleteReason: Copy.Explanation.AppLogs.safeReason,
        confidenceLevel: .high,
        usedBy: Copy.Explanation.AppLogs.usedBy,
        recoveryNote: Copy.Explanation.AppLogs.recovery,
        defaultSelected: true
    )

    private static let xcodeDerivedData = CleaningExplanation(
        name: Copy.Explanation.XcodeDerivedData.name,
        safetyLevel: .caution,
        what: Copy.Explanation.XcodeDerivedData.what,
        why: Copy.Explanation.XcodeDerivedData.why,
        impact: Copy.Explanation.XcodeDerivedData.impact,
        safeToDeleteReason: Copy.Explanation.XcodeDerivedData.safeReason,
        confidenceLevel: .high,
        usedBy: Copy.Explanation.XcodeDerivedData.usedBy,
        recoveryNote: Copy.Explanation.XcodeDerivedData.recovery,
        defaultSelected: false
    )

    private static let npmCache = CleaningExplanation(
        name: Copy.Explanation.NpmCache.name,
        safetyLevel: .caution,
        what: Copy.Explanation.NpmCache.what,
        why: Copy.Explanation.NpmCache.why,
        impact: Copy.Explanation.NpmCache.impact,
        safeToDeleteReason: Copy.Explanation.NpmCache.safeReason,
        confidenceLevel: .high,
        usedBy: Copy.Explanation.NpmCache.usedBy,
        recoveryNote: Copy.Explanation.NpmCache.recovery,
        defaultSelected: false
    )

    private static let userCacheFolder = CleaningExplanation(
        name: Copy.Explanation.UserCacheFolder.name,
        safetyLevel: .caution,
        what: Copy.Explanation.UserCacheFolder.what,
        why: Copy.Explanation.UserCacheFolder.why,
        impact: Copy.Explanation.UserCacheFolder.impact,
        safeToDeleteReason: Copy.Explanation.UserCacheFolder.safeReason,
        confidenceLevel: .medium,
        usedBy: Copy.Explanation.UserCacheFolder.usedBy,
        recoveryNote: Copy.Explanation.UserCacheFolder.recovery,
        defaultSelected: false
    )
}
