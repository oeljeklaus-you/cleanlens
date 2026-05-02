import SwiftUI

struct UpgradeSheet: View {
    let message: String
    let onActivate: (String) async -> String?
    let onContinueWithFree: () -> Void

    @State private var licenseKey = ""
    @State private var errorMessage: String?
    @State private var isActivating = false
    @FocusState private var isKeyFocused: Bool

    private let reasons = [
        "Clean more space with confidence",
        "Safely review advanced items",
        "Avoid deleting something important",
        "Built for developers (Xcode, npm, cache)"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Label(Copy.Monetization.unlockTitle, systemImage: "lock.open.fill")
                    .font(.title2.weight(.semibold))

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Why upgrade:")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(reasons, id: \.self) { reason in
                    Label(reason, systemImage: "circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(Copy.Monetization.licensePrompt)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(Copy.Monetization.licensePlaceholder, text: $licenseKey)
                    .textFieldStyle(.roundedBorder)
                    .focused($isKeyFocused)
                    .onSubmit {
                        activate()
                    }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Button(Copy.Monetization.continueWithFree) {
                    onContinueWithFree()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button {
                    activate()
                } label: {
                    if isActivating {
                        ProgressView()
                            .controlSize(.small)
                            .frame(minWidth: 72)
                    } else {
                        Text(Copy.Monetization.activate)
                            .frame(minWidth: 88)
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(isActivating)
            }
        }
        .padding(24)
        .frame(minWidth: 560)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color.accentColor.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            isKeyFocused = true
        }
    }

    private func activate() {
        let trimmedKey = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedKey.isEmpty == false else {
            errorMessage = Copy.Monetization.enterKeyPrompt
            return
        }

        isActivating = true
        errorMessage = nil

        Task {
            let error = await onActivate(trimmedKey)

            await MainActor.run {
                isActivating = false
                errorMessage = error
            }
        }
    }
}
