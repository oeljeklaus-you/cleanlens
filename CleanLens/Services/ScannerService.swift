import Foundation

struct ScannerService {
    private let fileManager: FileManager
    private let homeDirectory: URL

    init(fileManager: FileManager = .default, homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.fileManager = fileManager
        self.homeDirectory = homeDirectory
    }

    func scan() async -> [ScanItem] {
        await Task.detached(priority: .userInitiated) {
            var items: [ScanItem] = []

            items.append(contentsOf: self.scanKnownLocations())
            items.append(contentsOf: self.scanLargeDownloads())

            return items
                .filter { $0.size > 0 }
                .sorted { $0.size > $1.size }
        }.value
    }

    private func scanKnownLocations() -> [ScanItem] {
        knownPaths().compactMap { path in
            let expandedPath = expandHome(in: path)
            guard fileManager.fileExists(atPath: expandedPath) else {
                return nil
            }

            let size = FileUtils.getFolderSize(path: expandedPath)
            guard size > 0 else {
                return nil
            }

            let explanation = CleaningExplanationLibrary.explanation(forKnownPath: expandedPath)
            return makeScanItem(path: expandedPath, size: size, explanation: explanation)
        }
    }

    private func scanLargeDownloads() -> [ScanItem] {
        let downloadsURL = homeDirectory.appendingPathComponent("Downloads", isDirectory: true)
        guard fileManager.fileExists(atPath: downloadsURL.path) else {
            return []
        }

        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileSizeKey,
            .totalFileAllocatedSizeKey,
            .contentAccessDateKey,
            .contentModificationDateKey
        ]

        guard let children = try? fileManager.contentsOfDirectory(
            at: downloadsURL,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let threshold: Int64 = 100 * 1024 * 1024

        return children.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: keys),
                  values.isRegularFile == true
            else {
                return nil
            }

            let size = Int64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
            guard size > threshold else {
                return nil
            }

            let explanation = CleaningExplanationLibrary.largeDownloadExplanation(fileName: url.lastPathComponent)
            return ScanItem(
                name: explanation.name,
                path: url.path,
                size: size,
                lastAccessDate: values.contentAccessDate ?? values.contentModificationDate,
                safetyLevel: explanation.safetyLevel,
                isSelected: explanation.defaultSelected,
                what: explanation.what,
                why: explanation.why,
                impact: explanation.impact,
                safeToDeleteReason: explanation.safeToDeleteReason,
                confidenceLevel: explanation.confidenceLevel,
                usedBy: explanation.usedBy,
                recoveryNote: explanation.recoveryNote
            )
        }
    }

    private func makeScanItem(path: String, size: Int64, explanation: CleaningExplanation) -> ScanItem {
        ScanItem(
            name: explanation.name,
            path: path,
            size: size,
            lastAccessDate: FileUtils.getLastAccessDate(path: path),
            safetyLevel: explanation.safetyLevel,
            isSelected: explanation.defaultSelected,
            what: explanation.what,
            why: explanation.why,
            impact: explanation.impact,
            safeToDeleteReason: explanation.safeToDeleteReason,
            confidenceLevel: explanation.confidenceLevel,
            usedBy: explanation.usedBy,
            recoveryNote: explanation.recoveryNote
        )
    }

    private func knownPaths() -> [String] {
        [
            "~/Library/Caches",
            "~/Library/Logs",
            "~/Library/Developer/Xcode/DerivedData",
            "~/.npm",
            "~/.cache"
        ]
    }

    private func expandHome(in path: String) -> String {
        guard path.hasPrefix("~/") else {
            return path
        }

        return homeDirectory.appendingPathComponent(String(path.dropFirst(2))).path
    }
}
