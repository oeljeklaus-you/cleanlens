import Foundation
import SwiftUI

@MainActor
final class ScanViewModel: ObservableObject {
    @Published private(set) var items: [ScanItem] = []
    @Published private(set) var isScanning = false
    @Published private(set) var isCleaning = false
    @Published private(set) var cleanedSize: Int64 = 0
    @Published private(set) var lastCleanupResult: CleanupPresentation?
    @Published private(set) var cleanupFailures: [CleanupFailure] = []

    private let scannerService: ScannerService
    private let cleanupService: CleanupService

    init(
        scannerService: ScannerService = ScannerService(),
        cleanupService: CleanupService = CleanupService()
    ) {
        self.scannerService = scannerService
        self.cleanupService = cleanupService
    }

    var totalSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }

    var selectedSize: Int64 {
        selectedItems.reduce(0) { $0 + $1.size }
    }

    var safeSize: Int64 {
        items.filter { $0.safetyLevel == .safe }.reduce(0) { $0 + $1.size }
    }

    var cautionSize: Int64 {
        items.filter { $0.safetyLevel == .caution }.reduce(0) { $0 + $1.size }
    }

    var lockedSize: Int64 {
        cautionSize
    }

    var estimatedSizeAfter: Int64 {
        max(totalSize - selectedSize, 0)
    }

    var selectedItems: [ScanItem] {
        items.filter(\.isSelected)
    }

    var reviewItems: [ScanItem] {
        let failureItems = cleanupFailures.map(\.item)
        let riskyItems = items.filter { $0.safetyLevel == .risky }
        let combined = failureItems + riskyItems
        var seenIDs: Set<UUID> = []

        return combined.filter { item in
            if seenIDs.contains(item.id) {
                return false
            }

            seenIDs.insert(item.id)
            return true
        }
    }

    var selectedItemCount: Int {
        selectedItems.count
    }

    var hasSelection: Bool {
        selectedItems.isEmpty == false
    }

    var hasScanned: Bool {
        items.isEmpty == false || cleanedSize > 0 || cleanupFailures.isEmpty == false
    }

    func scan() {
        isScanning = true
        lastCleanupResult = nil
        cleanupFailures = []

        Task {
            let scannedItems = await scannerService.scan()
            withAnimation(.easeInOut(duration: 0.22)) {
                items = scannedItems
                normalizeSelectionForCurrentPlan()
            }
            isScanning = false
        }
    }

    func setSelection(_ isSelected: Bool, for item: ScanItem) {
        guard item.safetyLevel != .risky,
              let index = items.firstIndex(where: { $0.id == item.id })
        else {
            return
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            items[index].isSelected = isSelected
        }
    }

    func clearCleanupResult() {
        lastCleanupResult = nil
    }

    func cleanSelected() {
        let allowsCautionItems = FeatureGate.isEnabled(.cleanCaution)
        let itemsToDelete = selectedItems.filter { item in
            item.safetyLevel == .safe || allowsCautionItems
        }
        let cleanupService = cleanupService

        guard itemsToDelete.isEmpty == false else {
            return
        }

        guard FeatureGate.isEnabled(.batchClean) || itemsToDelete.count <= 1 else {
            return
        }

        isCleaning = true
        lastCleanupResult = nil
        cleanupFailures = []

        Task {
            let result = await Task.detached(priority: .userInitiated) {
                cleanupService.delete(items: itemsToDelete, allowCautionItems: allowsCautionItems)
            }.value

            cleanedSize += result.cleanedSize
            cleanupFailures = result.failedItems

            let deletedIDs = Set(result.deletedItems.map(\.id))
            withAnimation(.easeInOut(duration: 0.22)) {
                items.removeAll { deletedIDs.contains($0.id) }
            }

            if result.failedItems.isEmpty == false {
                let presentationKind: CleanupPresentation.Kind
                if result.failedItems.contains(where: { $0.message == Copy.SafetyDecision.permission }) {
                    presentationKind = .permission
                } else {
                    presentationKind = result.cleanedSize > 0 ? .partial : .needsReview(count: result.failedItems.count)
                }

                lastCleanupResult = CleanupPresentation(
                    kind: presentationKind,
                    cleanedSize: result.cleanedSize
                )
            } else if result.cleanedSize > 0 {
                lastCleanupResult = CleanupPresentation(kind: .success, cleanedSize: result.cleanedSize)
            }

            isCleaning = false
        }
    }

    func normalizeSelectionForCurrentPlan() {
        guard FeatureGate.isEnabled(.batchClean) == false else {
            return
        }

        var didKeepOneSafeSelection = false

        for index in items.indices {
            guard items[index].isSelected else {
                continue
            }

            if items[index].safetyLevel != .safe {
                items[index].isSelected = false
                continue
            }

            if didKeepOneSafeSelection {
                items[index].isSelected = false
            } else {
                didKeepOneSafeSelection = true
            }
        }
    }
}

struct CleanupPresentation: Equatable {
    enum Kind: Equatable {
        case success
        case partial
        case permission
        case needsReview(count: Int)
    }

    let kind: Kind
    let cleanedSize: Int64
}
