import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var licenseService: LicenseService
    @StateObject private var viewModel = ScanViewModel()
    @State private var isShowingReviewSheet = false
    @State private var activeDialog: ActiveDialog?
    @State private var showReviewOnly = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            SummaryView(
                totalFound: viewModel.totalSize,
                availableNow: viewModel.safeSize,
                lockedPro: viewModel.lockedSize,
                itemsSelected: viewModel.selectedItemCount
            )
            .padding(.horizontal, 24)
            .padding(.top, 18)

            scanResultsSection

            Divider()

            bottomActionBar
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onChange(of: licenseService.isProUnlocked) { _, _ in
            viewModel.normalizeSelectionForCurrentPlan()
        }
        .onChange(of: viewModel.lastCleanupResult) { _, result in
            guard let result else {
                return
            }

            activeDialog = .cleanup(result)
        }
        .sheet(isPresented: $isShowingReviewSheet) {
            ReviewCleanSheet(
                selectedItems: viewModel.selectedItems,
                selectedSize: viewModel.selectedSize,
                onCancel: {
                    isShowingReviewSheet = false
                },
            onConfirm: {
                    isShowingReviewSheet = false
                    viewModel.cleanSelected()
                }
            )
        }
        .sheet(item: Binding(
            get: { AppConfig.isPublicBeta ? nil : appState.activeMonetizationSheet },
            set: { appState.activeMonetizationSheet = $0 }
        )) { sheet in
            if AppConfig.isPublicBeta {
                EmptyView()
            } else {
                UpgradeSheet(
                    message: sheet.message,
                    onActivate: { key in
                        await activateLicense(key: key)
                    },
                    onContinueWithFree: {
                        appState.activeMonetizationSheet = nil
                    }
                )
            }
        }
        .alert(item: $activeDialog) { dialog in
            alert(for: dialog)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(Copy.App.name)
                    .font(.largeTitle.weight(.semibold))

                Text(Copy.App.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showReviewOnly = false
                viewModel.scan()
            } label: {
                Label(viewModel.isScanning ? Copy.App.scanningButton : Copy.App.scanButton, systemImage: "sparkle.magnifyingglass")
                    .frame(minWidth: 132)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isScanning || viewModel.isCleaning)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var scanResultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(viewModel.items.isEmpty ? Copy.App.resultsTitle : Copy.ScanComplete.title)
                    .font(.title3.weight(.semibold))

                Spacer()

                if viewModel.items.isEmpty == false {
                    if showReviewOnly {
                        Button(Copy.App.showAll) {
                            showReviewOnly = false
                        }
                        .buttonStyle(.link)
                    }

                    Text(showReviewOnly ? Copy.App.reviewingOnly : Copy.App.sortedBySize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            if !AppConfig.isPublicBeta, shouldShowProBanner {
                proBanner
                    .padding(.horizontal, 24)
            }

            if viewModel.isScanning {
                loadingState
            } else if viewModel.items.isEmpty {
                emptyOrSuccessState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        Text(Copy.ScanComplete.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 2)

                        ForEach(displayedItems) { item in
                            ScanItemCard(
                                item: item,
                                isHighlighted: item.size > 1_073_741_824,
                                isProLocked: item.safetyLevel == .caution && licenseService.isProUnlocked == false,
                                onSelectionChange: { isSelected in
                                    handleSelectionChange(isSelected, for: item)
                                },
                                onRiskReviewRequested: {
                                    activeDialog = .risk(item)
                                },
                                onLockedFeatureRequested: {
                                    appState.activeMonetizationSheet = .upgrade(
                                        message: Copy.Monetization.unlockToCleanItem
                                    )
                                }
                            )
                        }

                        if !AppConfig.isPublicBeta {
                            developerCleanupSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.05)

            Text(Copy.Scanning.title)
                .font(.headline)

            Text(Copy.Scanning.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private var emptyOrSuccessState: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.cleanedSize > 0 ? "checkmark.shield" : "folder.badge.magnifyingglass")
                .font(.system(size: 54))
                .foregroundStyle(viewModel.cleanedSize > 0 ? .green : .secondary)

            Text(emptyStateTitle)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private var bottomActionBar: some View {
        HStack(spacing: 16) {
            Label(Copy.App.bottomReminder, systemImage: "checkmark.shield")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                handleReviewCleanTap()
            } label: {
                Label(viewModel.isCleaning ? Copy.App.cleaningButton : Copy.App.reviewCleanButton, systemImage: "checkmark.shield")
                    .frame(minWidth: 150)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.hasSelection == false || viewModel.isScanning || viewModel.isCleaning)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.55))
    }

    private var displayedItems: [ScanItem] {
        showReviewOnly ? viewModel.reviewItems : viewModel.items
    }

    private var emptyStateTitle: String {
        if viewModel.cleanedSize > 0 {
            return Copy.Success.title()
        }

        return Copy.Empty.title
    }

    private var emptyStateMessage: String {
        if viewModel.cleanedSize > 0 {
            return Copy.Success.message(freed: FileUtils.formatBytes(viewModel.cleanedSize))
        }

        return Copy.Empty.message
    }

    private func alert(for dialog: ActiveDialog) -> Alert {
        switch dialog {
        case .cleanup(let result):
            return cleanupAlert(for: result)
        case .risk:
            return Alert(
                title: Text(Copy.Risk.title),
                message: Text("\(Copy.Risk.message)\n\n\(Copy.Risk.action)"),
                primaryButton: .default(Text(Copy.Risk.primaryButton)),
                secondaryButton: .cancel(Text(Copy.Risk.secondaryButton))
            )
        case .message(let title, let message):
            if AppConfig.isPublicBeta {
                return Alert(title: Text(title), message: Text(message))
            }

            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text(Copy.Success.button))
            )
        }
    }

    private func cleanupAlert(for result: CleanupPresentation) -> Alert {
        switch result.kind {
        case .success:
            return Alert(
                title: Text(Copy.Success.title()),
                message: Text(Copy.Success.message(freed: FileUtils.formatBytes(result.cleanedSize))),
                dismissButton: .default(Text(Copy.Success.button)) {
                    viewModel.clearCleanupResult()
                }
            )
        case .partial:
            return Alert(
                title: Text(Copy.Partial.title),
                message: Text(Copy.Partial.message),
                primaryButton: .default(Text(Copy.Partial.primaryButton)) {
                    showReviewOnly = true
                    viewModel.clearCleanupResult()
                },
                secondaryButton: .cancel(Text(Copy.Partial.secondaryButton)) {
                    viewModel.clearCleanupResult()
                }
            )
        case .permission:
            return Alert(
                title: Text(Copy.Permission.title),
                message: Text(Copy.Permission.message),
                primaryButton: .default(Text(Copy.Permission.allow)) {
                    openPrivacySettings()
                    viewModel.clearCleanupResult()
                },
                secondaryButton: .cancel(Text(Copy.Permission.skip)) {
                    viewModel.clearCleanupResult()
                }
            )
        case .needsReview(let count):
            return Alert(
                title: Text(Copy.NeedsReview.title(count: count)),
                message: Text("\(Copy.NeedsReview.message(count: count))\n\n\(Copy.NeedsReview.action)"),
                primaryButton: .default(Text(Copy.NeedsReview.primaryButton)) {
                    showReviewOnly = true
                    viewModel.clearCleanupResult()
                },
                secondaryButton: .cancel(Text(Copy.NeedsReview.secondaryButton)) {
                    viewModel.clearCleanupResult()
                }
            )
        }
    }

    private var shouldShowProBanner: Bool {
        licenseService.isProUnlocked == false
            && viewModel.items.isEmpty == false
            && viewModel.cautionSize > viewModel.safeSize
    }

    private var proBanner: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label(Copy.Monetization.bannerTitle, systemImage: "sparkles")
                    .font(.headline.weight(.semibold))

                Text(Copy.Monetization.unlockMessage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Text("You can clean \(FileUtils.formatBytes(viewModel.safeSize)) now. Pro unlocks \(FileUtils.formatBytes(viewModel.lockedSize)) more.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                appState.activeMonetizationSheet = .upgrade(message: Copy.Monetization.unlockMessage)
            } label: {
            Text(Copy.Monetization.unlockTitle)
                    .frame(minWidth: 140)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var developerCleanupSection: some View {
        let isProUnlocked = licenseService.isProUnlocked

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Developer Cleanup")
                        .font(.headline.weight(.semibold))

                    Text("Xcode DerivedData, npm cache, and .cache")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isProUnlocked == false {
                    Label(Copy.Monetization.unlockProToUse, systemImage: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                developerCleanupRow(
                    title: Copy.Explanation.XcodeDerivedData.name,
                    detail: Copy.Explanation.XcodeDerivedData.impact,
                    icon: "hammer"
                )

                developerCleanupRow(
                    title: Copy.Explanation.NpmCache.name,
                    detail: Copy.Explanation.NpmCache.impact,
                    icon: "shippingbox"
                )

                developerCleanupRow(
                    title: Copy.Explanation.UserCacheFolder.name,
                    detail: Copy.Explanation.UserCacheFolder.impact,
                    icon: "externaldrive"
                )
            }
            .padding(14)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .blur(radius: isProUnlocked ? 0 : 2.5)
        .overlay {
            if isProUnlocked == false {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.03))

                Text(Copy.Monetization.unlockProToUse)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(Color(nsColor: .windowBackgroundColor).opacity(0.92))
                    .clipShape(Capsule())
            }
        }
    }

    private func developerCleanupRow(title: String, detail: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 26, height: 26)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private func handleSelectionChange(_ isSelected: Bool, for item: ScanItem) {
        if AppConfig.isPublicBeta {
            viewModel.setSelection(isSelected, for: item)
            return
        }

        let isLocked = item.safetyLevel == .caution && licenseService.isProUnlocked == false

        if isLocked {
            appState.activeMonetizationSheet = .upgrade(message: Copy.Monetization.unlockToCleanItem)
            return
        }

        if isSelected
            && licenseService.isProUnlocked == false
            && viewModel.selectedItems.contains(where: { $0.id != item.id })
        {
            appState.activeMonetizationSheet = .upgrade(message: Copy.Monetization.unlockMessage)
            return
        }

        viewModel.setSelection(isSelected, for: item)
    }

    private func handleReviewCleanTap() {
        if AppConfig.isPublicBeta {
            isShowingReviewSheet = true
            return
        }

        if requiresUpgradeForSelectedItems {
            appState.activeMonetizationSheet = .upgrade(message: Copy.Monetization.unlockMessage)
            return
        }

        isShowingReviewSheet = true
    }

    private var requiresUpgradeForSelectedItems: Bool {
        if AppConfig.isPublicBeta {
            return false
        }

        guard licenseService.isProUnlocked == false else {
            return false
        }

        if viewModel.selectedItemCount > 1 {
            return true
        }

        return viewModel.selectedItems.contains { $0.safetyLevel == .caution }
    }

    private func activateLicense(key: String) async -> String? {
        guard AppConfig.isPublicBeta == false else {
            return nil
        }

        do {
            let unlocked = try await licenseService.activateLicense(key: key)

            guard unlocked else {
                return "The license key could not be activated."
            }

            await MainActor.run {
                appState.activeMonetizationSheet = nil
                viewModel.normalizeSelectionForCurrentPlan()
                activeDialog = .message(
                    title: "Pro unlocked",
                    message: "All Pro features are now available."
                )
            }

            return nil
        } catch {
            return error.localizedDescription
        }
    }

    private func openPrivacySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

private enum ActiveDialog: Identifiable {
    case cleanup(CleanupPresentation)
    case risk(ScanItem)
    case message(title: String, message: String)

    var id: String {
        switch self {
        case .cleanup(let result):
            return "cleanup-\(result.cleanedSize)-\(String(describing: result.kind))"
        case .risk(let item):
            return "risk-\(item.id.uuidString)"
        case .message(let title, let message):
            return "message-\(title)-\(message)"
        }
    }
}
