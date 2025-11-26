import SwiftUI

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
struct SettingsView: View {
    var onBack: () -> Void
    @EnvironmentObject var audio: MusicManager

    private enum AppConfig {
        static let appStoreID = "6754334159"
        static let supportEmail = "l.ventresca@huifengl.com"
        static let privacyLink = "https://docs.google.com/document/d/e/2PACX-1vRyMbCAwx-hwD7y0TOSlKkeOrAdOMnUeaCGfFwgKPHkwjt2wBbhP117g2qd5349S1nPyKGf_u5t6saJ/pub"

        static var appStoreURL: URL? {
            URL(string: "https://apps.apple.com/app/id6754334159")
        }
        static var privacyURL: URL? {
            URL(string: privacyLink)
        }
    }

    var body: some View {
        ZStack {
            Image("app_bg_main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image("app_btn_home")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                            .padding(.leading, 100)
                    }
                    Spacer()
                }
                Spacer()
                Button {
                    audio.toggleSound()
                    audio.isSoundEnabled
                        ? audio.resumeBGMIfNeeded() : audio.pauseBGM()
                } label: {
                    ZStack(alignment: .trailing) {
                        Image("app_btn_settings04")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)

                        Image(
                            audio.isSoundEnabled
                                ? "app_btn_on" : "app_btn_off"
                        )
                        .resizable()
                        .scaledToFit()
                        .offset(x: -15)
                        .offset(y: -4)
                        .frame(height: 27)
                    }
                }
                Button {
                    openPolicy()
                } label: {
                    Image("app_btn_settings03")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                }
                Button {
                    contactUs()
                } label: {
                    Image("app_btn_settings02")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                }
                Button {
                    shareApp()
                } label: {
                    Image("app_btn_settings01")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                }

                Spacer()

            }.padding(.top)

        }

    }

    private func shareApp() {
        guard
            ProcessInfo.processInfo.environment[
                "XCODE_RUNNING_FOR_PREVIEWS"
            ]
                == nil
        else {

            return
        }
        guard let url = AppConfig.appStoreURL else { return }
        let av = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(
            av,
            animated: true
        )
    }

    private func contactUs() {
        guard
            ProcessInfo.processInfo.environment[
                "XCODE_RUNNING_FOR_PREVIEWS"
            ]
                == nil
        else {

            return
        }
        let to = AppConfig.supportEmail
        if let url = URL(string: "mailto:\(to)") {
            UIApplication.shared.open(url)
        }
    }

    private func openPolicy() {
        guard
            ProcessInfo.processInfo.environment[
                "XCODE_RUNNING_FOR_PREVIEWS"
            ]
                == nil
        else {

            return
        }
        if let url = AppConfig.privacyURL {
            UIApplication.shared.open(url)
        }
    }

}
