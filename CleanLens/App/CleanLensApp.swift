import SwiftUI

@main
struct CleanLensApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var licenseService = LicenseService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(licenseService)
                .frame(minWidth: 900, minHeight: 640)
        }
        .windowStyle(.titleBar)
        .commands {
            CleanLensCommands(appState: appState)
        }
    }
}

struct CleanLensCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandMenu("License") {
            Button(Copy.Monetization.activationMenuTitle) {
                appState.activeMonetizationSheet = .activation(message: Copy.Monetization.activationMessage)
            }
        }
    }
}
