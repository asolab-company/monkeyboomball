import SwiftUI

enum AppRoute {
    case loading
    case menu
    case game
    case settings
    case info
}

struct Main: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            switch route {
            case .loading:
                LoadView {
                    route = .menu
                }

            case .menu:
                MenuView(
                    onPlay: { route = .game },
                    onSettings: { route = .settings },
                    onInfo: { route = .info }
                )

            case .game:
                GameView(
                    onBack: { route = .menu }
                )

            case .settings:
                SettingsView(
                    onBack: { route = .menu }
                )

            case .info:
                InfoView(
                    onBack: { route = .menu }
                )
            }
        }
    }
}
