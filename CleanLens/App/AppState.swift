import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var activeMonetizationSheet: MonetizationSheet?
}

enum MonetizationSheet: Identifiable, Equatable {
    case upgrade(message: String)
    case activation(message: String)

    var id: String {
        switch self {
        case .upgrade(let message):
            return "upgrade-\(message)"
        case .activation(let message):
            return "activation-\(message)"
        }
    }

    var message: String {
        switch self {
        case .upgrade(let message), .activation(let message):
            return message
        }
    }
}
