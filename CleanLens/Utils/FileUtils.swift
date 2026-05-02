import Foundation

enum FileUtils {
    static func getFolderSize(path: String) -> Int64 {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return 0
        }

        if !isDirectory.boolValue {
            return fileSize(atPath: path)
        }

        let url = URL(fileURLWithPath: path)
        let resourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .isDirectoryKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey
        ]

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) else {
            return 0
        }

        var totalSize: Int64 = 0

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys) else {
                continue
            }

            if resourceValues.isDirectory == true {
                continue
            }

            let allocatedSize = resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
            totalSize += Int64(allocatedSize)
        }

        return totalSize
    }

    static func getLastAccessDate(path: String) -> Date? {
        let url = URL(fileURLWithPath: path)

        if let values = try? url.resourceValues(forKeys: [.contentAccessDateKey, .contentModificationDateKey]) {
            return values.contentAccessDate ?? values.contentModificationDate
        }

        return nil
    }

    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }

    private static func fileSize(atPath path: String) -> Int64 {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
            return 0
        }

        return (attributes[.size] as? NSNumber)?.int64Value ?? 0
    }
}
