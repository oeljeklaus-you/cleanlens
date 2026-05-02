import SwiftUI

struct ScanItemRow: View {
    let item: ScanItem
    let isHighlighted: Bool
    let isProLocked: Bool
    let onSelectionChange: (Bool) -> Void
    let onLockedFeatureRequested: () -> Void

    var body: some View {
        ScanItemCard(
            item: item,
            isHighlighted: isHighlighted,
            isProLocked: isProLocked,
            onSelectionChange: onSelectionChange,
            onRiskReviewRequested: {},
            onLockedFeatureRequested: onLockedFeatureRequested
        )
    }
}
