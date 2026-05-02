import SwiftUI

struct SafetyBadge: View {
    let safetyLevel: SafetyLevel

    var body: some View {
        Label(safetyLevel.title, systemImage: symbolName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel(accessibilityText)
    }

    private var symbolName: String {
        switch safetyLevel {
        case .safe:
            return "checkmark.circle.fill"
        case .caution:
            return "circle.fill"
        case .risky:
            return "shield.lefthalf.filled"
        }
    }

    private var color: Color {
        switch safetyLevel {
        case .safe:
            return .green
        case .caution:
            return .yellow
        case .risky:
            return .red
        }
    }

    private var accessibilityText: String {
        switch safetyLevel {
        case .safe:
            return Copy.Safety.safeAccessibility
        case .caution:
            return Copy.Safety.cautionAccessibility
        case .risky:
            return Copy.Safety.riskyAccessibility
        }
    }
}
