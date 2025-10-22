import SwiftUI

@main
struct Monkey_Boom_BallApp: App {

    @StateObject var audio = MusicManager.shared
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            Main().environmentObject(audio)
                .onAppear {
                    audio.startBGM()
                }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .background:
                        audio.willEnterBackground()
                    case .inactive:
                        break
                    case .active:
                        audio.didEnterForeground()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
