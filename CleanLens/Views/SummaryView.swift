import SwiftUI

struct SummaryView: View {
    let totalFound: Int64
    let availableNow: Int64
    let lockedPro: Int64
    let itemsSelected: Int

    var body: some View {
        HStack(spacing: 14) {
            metricCell(
                title: Copy.Summary.totalFound,
                value: FileUtils.formatBytes(totalFound),
                symbol: "internaldrive",
                tint: .blue
            )

            metricCell(
                title: Copy.Summary.availableNow,
                value: FileUtils.formatBytes(availableNow),
                symbol: "checkmark.circle",
                tint: .teal
            )

            if AppConfig.isPublicBeta {
                metricCell(
                    title: Copy.Summary.itemsSelected,
                    value: "\(itemsSelected)",
                    symbol: "list.bullet.rectangle",
                    tint: .indigo
                )
            } else {
                metricCell(
                    title: Copy.Summary.lockedPro,
                    value: FileUtils.formatBytes(lockedPro),
                    symbol: "lock.fill",
                    tint: .orange,
                    isEmphasized: true
                )
            }
        }
        .animation(.easeInOut(duration: 0.22), value: totalFound)
        .animation(.easeInOut(duration: 0.22), value: availableNow)
        .animation(.easeInOut(duration: 0.22), value: lockedPro)
        .animation(.easeInOut(duration: 0.22), value: itemsSelected)
    }

    private func metricCell(title: String, value: String, symbol: String, tint: Color, isEmphasized: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 30, height: 30)
                .foregroundStyle(tint)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(isEmphasized ? .title2.weight(.bold).monospacedDigit() : .title3.weight(.semibold).monospacedDigit())
                    .foregroundStyle(isEmphasized ? Color.orange : .primary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(isEmphasized ? Color.orange.opacity(0.08) : Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isEmphasized ? Color.orange.opacity(0.3) : Color.primary.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
