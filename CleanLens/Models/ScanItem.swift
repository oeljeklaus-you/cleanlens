import Foundation

enum SafetyLevel: String, CaseIterable, Identifiable {
    case safe
    case caution
    case risky

    var id: String { rawValue }

    var title: String {
        switch self {
        case .safe:
            return Copy.Safety.safe
        case .caution:
            return Copy.Safety.caution
        case .risky:
            return Copy.Safety.risky
        }
    }
}

enum ConfidenceLevel: String, CaseIterable, Identifiable {
    case high
    case medium
    case low

    var id: String { rawValue }

    var title: String {
        switch self {
        case .high:
            return Copy.Safety.highConfidence
        case .medium:
            return Copy.Safety.mediumConfidence
        case .low:
            return Copy.Safety.lowConfidence
        }
    }
}

struct ScanItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let size: Int64
    let lastAccessDate: Date?
    let safetyLevel: SafetyLevel
    var isSelected: Bool
    let what: String
    let why: String
    let impact: String
    let safeToDeleteReason: String
    let confidenceLevel: ConfidenceLevel
    let usedBy: String
    let recoveryNote: String

    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        size: Int64,
        lastAccessDate: Date?,
        safetyLevel: SafetyLevel,
        isSelected: Bool = false,
        what: String,
        why: String,
        impact: String,
        safeToDeleteReason: String,
        confidenceLevel: ConfidenceLevel,
        usedBy: String,
        recoveryNote: String
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.size = size
        self.lastAccessDate = lastAccessDate
        self.safetyLevel = safetyLevel
        self.isSelected = safetyLevel == .risky ? false : isSelected
        self.what = what
        self.why = why
        self.impact = impact
        self.safeToDeleteReason = safeToDeleteReason
        self.confidenceLevel = confidenceLevel
        self.usedBy = usedBy
        self.recoveryNote = recoveryNote
    }
}
