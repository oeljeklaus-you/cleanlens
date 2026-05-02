import Foundation

struct CleanupResult {
    let deletedItems: [ScanItem]
    let failedItems: [CleanupFailure]
    let cleanedSize: Int64
}

struct CleanupFailure: Identifiable, Hashable {
    let id = UUID()
    let item: ScanItem
    let message: String
}

struct CleanupService {
    private let fileManager: FileManager
    private let homeDirectory: URL

    init(fileManager: FileManager = .default, homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.fileManager = fileManager
        self.homeDirectory = homeDirectory.standardizedFileURL
    }

    func delete(items: [ScanItem], allowCautionItems: Bool = false) -> CleanupResult {
        var deletedItems: [ScanItem] = []
        var failedItems: [CleanupFailure] = []
        var cleanedSize: Int64 = 0

        for item in items {
            guard item.safetyLevel != .caution || allowCautionItems else {
                failedItems.append(
                    CleanupFailure(
                        item: item,
                        message: Copy.SafetyDecision.proRequired
                    )
                )
                continue
            }

            guard item.safetyLevel != .risky else {
                failedItems.append(
                    CleanupFailure(
                        item: item,
                        message: Copy.SafetyDecision.riskyItem
                    )
                )
                continue
            }

            guard isAllowedUserPath(item.path) else {
                failedItems.append(
                    CleanupFailure(
                        item: item,
                        message: Copy.SafetyDecision.outsideUserFolder
                    )
                )
                continue
            }

            guard fileManager.fileExists(atPath: item.path) else {
                deletedItems.append(item)
                continue
            }

            let result = deleteItemSafely(item)
            cleanedSize += result.cleanedSize

            if result.isFullyDeleted {
                deletedItems.append(item)
            }

            if result.failures.isEmpty == false {
                failedItems.append(
                    CleanupFailure(
                        item: item,
                        message: result.userMessage
                    )
                )
            }
        }

        return CleanupResult(deletedItems: deletedItems, failedItems: failedItems, cleanedSize: cleanedSize)
    }

    private func deleteItemSafely(_ item: ScanItem) -> ItemDeleteResult {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory)

        if isDirectory.boolValue {
            return deleteDirectoryContents(atPath: item.path)
        }

        return deleteFile(atPath: item.path)
    }

    private func deleteDirectoryContents(atPath path: String) -> ItemDeleteResult {
        do {
            let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
            let contents = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
                options: [.skipsHiddenFiles]
            )

            guard contents.isEmpty == false else {
                return ItemDeleteResult(isFullyDeleted: true, cleanedSize: 0, failures: [])
            }

            var cleanedSize: Int64 = 0
            var failures: [String] = []

            for url in contents {
                let itemSize = FileUtils.getFolderSize(path: url.path)

                do {
                    try fileManager.removeItem(at: url)
                    cleanedSize += itemSize
                } catch {
                    failures.append(Copy.SafetyDecision.unavailable)
                }
            }

            let fullyDeleted = failures.isEmpty
            return ItemDeleteResult(isFullyDeleted: fullyDeleted, cleanedSize: cleanedSize, failures: failures)
        } catch {
            return ItemDeleteResult(
                isFullyDeleted: false,
                cleanedSize: 0,
                failures: [Copy.SafetyDecision.permission]
            )
        }
    }

    private func deleteFile(atPath path: String) -> ItemDeleteResult {
        let size = FileUtils.getFolderSize(path: path)

        do {
            try fileManager.removeItem(atPath: path)
            return ItemDeleteResult(isFullyDeleted: true, cleanedSize: size, failures: [])
        } catch {
            return ItemDeleteResult(isFullyDeleted: false, cleanedSize: 0, failures: [Copy.SafetyDecision.unavailable])
        }
    }

    private func isAllowedUserPath(_ path: String) -> Bool {
        let standardizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
        let homePath = homeDirectory.path

        guard standardizedPath.hasPrefix(homePath + "/") else {
            return false
        }

        let blockedPrefixes = [
            "/System/",
            "/Library/",
            "/Applications/",
            "/private/",
            "/usr/",
            "/bin/",
            "/sbin/",
            "/var/"
        ]

        return !blockedPrefixes.contains { standardizedPath.hasPrefix($0) }
    }
}

private struct ItemDeleteResult {
    let isFullyDeleted: Bool
    let cleanedSize: Int64
    let failures: [String]

    var userMessage: String {
        failures.first ?? Copy.SafetyDecision.unavailable
    }
}
