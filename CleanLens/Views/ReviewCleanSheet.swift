import SwiftUI

struct ReviewCleanSheet: View {
    let selectedItems: [ScanItem]
    let selectedSize: Int64
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Copy.PreClean.title)
                    .font(.title2.weight(.semibold))

                Text(Copy.PreClean.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(selectedItems) { item in
                        reviewRow(for: item)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(minHeight: 180, maxHeight: 340)

            safetyReminder

            HStack {
                Text(Copy.PreClean.selectedAmount(FileUtils.formatBytes(selectedSize)))
                    .font(.headline.monospacedDigit())

                Spacer()

                Button(Copy.PreClean.cancel) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button(Copy.PreClean.confirm) {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(minWidth: 620)
    }

    private func reviewRow(for item: ScanItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(item.name)
                    .font(.headline)

                SafetyBadge(safetyLevel: item.safetyLevel)

                Spacer()

                Text(FileUtils.formatBytes(item.size))
                    .font(.headline.weight(.bold).monospacedDigit())
            }

            Text(item.impact)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var safetyReminder: some View {
        Label(
            Copy.PreClean.impact,
            systemImage: "info.circle"
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
