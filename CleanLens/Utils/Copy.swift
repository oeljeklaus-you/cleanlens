import Foundation

enum Copy {
    enum App {
        static let name = "CleanLens"
        static let subtitle = "Understand what you’re removing before you clean."
        static let scanButton = "Scan My Mac"
        static let scanningButton = "Scanning"
        static let reviewCleanButton = "Review"
        static let cleaningButton = "Cleaning"
        static let resultsTitle = "Scan Results"
        static let sortedBySize = "Sorted by size"
        static let bottomReminder = "Only selected user-folder items are cleaned. Items that need extra care stay unselected."
        static let showAll = "Show All"
        static let reviewingOnly = "Showing items that need review"
    }

    enum Monetization {
        static let unlockTitle = "Unlock full cleanup"
        static let unlockMessage = "CleanLens found more you can safely clean."
        static let activate = "Activate"
        static let continueWithFree = "Continue with Free"
        static let licensePrompt = "Enter your license key"
        static let licensePlaceholder = "CLEANLENS_PRO"
        static let enterKeyPrompt = "Enter a license key to continue."
        static let proRequired = "Pro required"
        static let unlockToCleanItem = "Unlock to clean this item safely"
        static let bannerTitle = "More space available with Pro"
        static let activationMenuTitle = "Enter License Key"
        static let unlockProToUse = "Unlock Pro to use"
        static let activationMessage = "Enter your license key to unlock Pro."
    }

    enum Scanning {
        static let title = "Scanning your Mac safely"
        static let message = "CleanLens is checking common cache and temporary files. Nothing will be removed without your review."
    }

    enum ScanComplete {
        static let title = "Here’s what we found"
        static let message = "CleanLens found items that may be safe to clean. Each item includes an explanation so you can decide with confidence."
    }

    enum NeedsReview {
        static func title(count: Int) -> String {
            "Some items require your review"
        }

        static func message(count: Int) -> String {
            "CleanLens skipped \(count) item(s) to keep your system safe. These items may affect app performance or contain important data."
        }

        static let action = "Please review them before deciding to clean."
        static let primaryButton = "Review Items"
        static let secondaryButton = "OK"
    }

    enum PreClean {
        static let title = "Review before cleaning"
        static let message = "You’re about to remove selected items. CleanLens only removes what you choose."
        static let impact = "Some apps may recreate these files. They may open slightly slower the next time."
        static let confirm = "Clean Selected"
        static let cancel = "Cancel"
        static func selectedAmount(_ amount: String) -> String {
            "Selected: \(amount)"
        }
    }

    enum Success {
        static func title() -> String {
            "Cleanup complete"
        }

        static func message(freed: String) -> String {
            "You freed up \(freed) of space. Some apps may rebuild cache files over time."
        }

        static let button = "Done"
    }

    enum Partial {
        static let title = "Some items were not removed"
        static let message = "CleanLens skipped a few items to keep your system safe. You can review them and decide manually."
        static let primaryButton = "Review"
        static let secondaryButton = "OK"
    }

    enum Risk {
        static let title = "This item needs extra care"
        static let message = "Removing this item may affect how an app works or remove important data."
        static let action = "We recommend reviewing it before cleaning."
        static let primaryButton = "Review Details"
        static let secondaryButton = "Cancel"
    }

    enum Permission {
        static let title = "Permission needed"
        static let message = "CleanLens needs access to this folder to analyze it. You can allow access or skip this item."
        static let allow = "Allow Access"
        static let skip = "Skip"
    }

    enum Empty {
        static let title = "Nothing to clean right now"
        static let message = "Your Mac looks clean. We’ll keep watching for items that can be safely removed."
    }

    enum Summary {
        static let totalFound = "Total found"
        static let availableNow = "Available now"
        static let lockedPro = "Locked (Pro)"
    }

    enum Item {
        static let largeItem = "Over 1 GB"
        static func usedBy(_ owner: String) -> String {
            "Used by \(owner)"
        }

        static let lastUsedUnknown = "Last used unknown"
        static func lastUsed(_ date: String) -> String {
            "Last used \(date)"
        }

        static func confidence(_ value: String) -> String {
            "Confidence: \(value)"
        }

        static let what = "What is this?"
        static let why = "Why is it here?"
        static let impact = "What happens if I clean it?"
        static let safeToClean = "Safe to clean?"
        static let recovery = "Can I get it back?"
    }

    enum Safety {
        static let safe = "Safe"
        static let caution = "Review"
        static let risky = "Needs extra care"
        static let highConfidence = "High"
        static let mediumConfidence = "Medium"
        static let lowConfidence = "Low"

        static let safeAccessibility = "Safe. Usually safe to clean."
        static let cautionAccessibility = "Review. Safe for most users, but may have temporary side effects."
        static let riskyAccessibility = "Needs extra care. CleanLens will not clean this automatically."
    }

    enum SafetyDecision {
        static let riskyItem = "CleanLens left this item in place because it needs extra care."
        static let outsideUserFolder = "CleanLens left this item in place because it is outside your user folder."
        static let proRequired = "CleanLens requires Pro to clean this item."
        static let unavailable = "CleanLens could not review this item right now, so it was left in place."
        static let permission = "CleanLens needs your permission before it can review this item."
    }

    enum Explanation {
        enum LargeDownload {
            static let what = "This is a large file in your Downloads folder."
            static let why = "Downloaded installers, videos, archives, and documents often remain here after use."
            static let impact = "Cleaning this file removes it from your Mac, so only choose it if you recognize it and no longer need it."
            static let safeReason = "This item is user-created or user-downloaded, so CleanLens leaves the decision to you."
            static let usedBy = "You"
            static let recovery = "You may need to download the file again if you clean it."
        }

        enum AppCaches {
            static let name = "App Caches"
            static let what = "Temporary files saved by apps to speed up loading."
            static let why = "Apps store images, previews, downloaded data, and temporary resources here so they do not need to recreate them every time."
            static let impact = "Apps may open a little slower the next time. No personal documents or account data should be removed."
            static let safeReason = "This folder is designed for temporary cache data and apps can usually rebuild it when needed."
            static let usedBy = "Many installed apps"
            static let recovery = "Apps will recreate needed cache files automatically."
        }

        enum AppLogs {
            static let name = "App Logs"
            static let what = "Diagnostic text files created by apps and macOS components."
            static let why = "Apps write logs to help diagnose crashes, unusual behavior, or background activity."
            static let impact = "Cleaning logs frees space but removes older diagnostic history. It should not affect normal app usage."
            static let safeReason = "Logs are not required for apps to run."
            static let usedBy = "Apps and macOS services"
            static let recovery = "New logs will be created automatically when needed."
        }

        enum XcodeDerivedData {
            static let name = "Xcode DerivedData"
            static let what = "Build cache generated by Xcode while compiling projects."
            static let why = "Xcode stores intermediate build files to make future builds faster."
            static let impact = "Your next build may take longer. Projects and source code will not be removed."
            static let safeReason = "DerivedData can usually be regenerated by Xcode."
            static let usedBy = "Xcode"
            static let recovery = "Xcode will recreate this data during future builds."
        }

        enum NpmCache {
            static let name = "npm Cache"
            static let what = "Downloaded package cache used by npm."
            static let why = "npm stores packages locally to speed up installs and reduce repeated downloads."
            static let impact = "Future npm install commands may be slower and may re-download packages."
            static let safeReason = "npm can rebuild this cache."
            static let usedBy = "npm / Node.js projects"
            static let recovery = "npm will recreate cache files as packages are installed."
        }

        enum UserCacheFolder {
            static let name = "User Cache Folder"
            static let what = "Temporary cache data created by command-line tools and apps."
            static let why = "Developer tools and apps store temporary files here to avoid recalculating or re-downloading data."
            static let impact = "Some tools may run slower the next time."
            static let safeReason = "Most data here is cache-like, but contents vary by app."
            static let usedBy = "Developer tools and apps"
            static let recovery = "Most tools will recreate required cache files automatically."
        }
    }
}
