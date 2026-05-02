import SwiftUI

struct ScanItemCard: View {
    let item: ScanItem
    let isHighlighted: Bool
    let isProLocked: Bool
    let onSelectionChange: (Bool) -> Void
    let onRiskReviewRequested: () -> Void
    let onLockedFeatureRequested: () -> Void

    @State private var isExpanded = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: onSelectionChange
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()
                .disabled(item.safetyLevel == .risky || isProLocked)
                .padding(.top, 2)

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isExpanded.toggle()
                    }

                    if item.safetyLevel == .risky {
                        onRiskReviewRequested()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            SafetyBadge(safetyLevel: item.safetyLevel)

                            if isProLocked {
                                Label(Copy.Monetization.proRequired, systemImage: "lock.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.08))
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        onLockedFeatureRequested()
                                    }
                            }

                            if isHighlighted {
                                Label(Copy.Item.largeItem, systemImage: "internaldrive")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.orange)
                            }

                            Spacer(minLength: 12)

                            Text(FileUtils.formatBytes(item.size))
                                .font(.headline.weight(.bold).monospacedDigit())
                                .foregroundStyle(isHighlighted ? .orange : .primary)
                                .multilineTextAlignment(.trailing)
                                .frame(minWidth: 110, alignment: .trailing)

                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }

                        Text(item.what)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)

                        HStack(spacing: 10) {
                            Label(lastUsedText, systemImage: "clock")
                            Label(Copy.Item.usedBy(item.usedBy), systemImage: "person.crop.circle")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    explanationRow(title: Copy.Item.what, text: item.what)
                    explanationRow(title: Copy.Item.why, text: item.why)
                    explanationRow(title: Copy.Item.impact, text: item.impact)
                    explanationRow(title: Copy.Item.safeToClean, text: item.safeToDeleteReason)
                    explanationRow(title: Copy.Item.recovery, text: item.recoveryNote)

                    HStack(spacing: 10) {
                        Label(Copy.Item.confidence(item.confidenceLevel.title), systemImage: "gauge.with.dots.needle.67percent")
                        Label(item.path, systemImage: "folder")
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.18), value: item.isSelected)
    }

    private var backgroundColor: Color {
        if item.isSelected {
            return Color.accentColor.opacity(0.08)
        }

        if isHighlighted {
            return Color.orange.opacity(0.06)
        }

        return Color(nsColor: .textBackgroundColor)
    }

    private var borderColor: Color {
        if item.isSelected {
            return Color.accentColor.opacity(0.28)
        }

        return Color.primary.opacity(0.06)
    }

    private var lastUsedText: String {
        guard let date = item.lastAccessDate else {
            return Copy.Item.lastUsedUnknown
        }

        return Copy.Item.lastUsed(Self.dateFormatter.string(from: date))
    }

    private func explanationRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
