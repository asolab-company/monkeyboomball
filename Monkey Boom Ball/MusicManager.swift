import AVFoundation
import Combine
import Foundation

final class MusicManager: ObservableObject {
    static let shared = MusicManager()
    private var pausedByApp = false

    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Self.udKeySound)
            isSoundEnabled ? resumeBGMIfNeeded() : pauseBGM()
        }
    }

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private var wasBgmPlayingBeforeBackground = false

    private static let udKeySound = "sound"

    private let bgmFile = "m_bg.mp3"
    private let shootFx = "m_tap.mp3"
    private let boomFx = "m_boom.mp3"
    private let overFx = "m_bonus.mp3"
    private let winFx = "m_win.mp3"

    private init() {
        let def = UserDefaults.standard.object(forKey: Self.udKeySound) as? Bool
        isSoundEnabled = def ?? true

        configureSession()
        observeInterruptions()
    }

    private func configureSession() {
        do {

            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {

        }
    }

    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self else { return }
            guard let info = note.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey]
                    as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }

            if type == .began {
                self.wasBgmPlayingBeforeBackground =
                    self.bgmPlayer?.isPlaying == true
                self.pauseBGM()

            } else if type == .ended {
                let optValue =
                    info[AVAudioSessionInterruptionOptionKey] as? UInt
                let options = AVAudioSession.InterruptionOptions(
                    rawValue: optValue ?? 0
                )
                if options.contains(.shouldResume),
                    self.wasBgmPlayingBeforeBackground, self.isSoundEnabled
                {
                    self.resumeBGMIfNeeded()

                }
            }
        }
    }

    func startBGM() {
        guard isSoundEnabled else {

            return
        }
        if bgmPlayer == nil {
            bgmPlayer = loadPlayer(file: bgmFile)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 1.0
        }
        guard let p = bgmPlayer else {

            return
        }
        p.play()

    }

    func pauseBGM() {
        bgmPlayer?.pause()

    }
    func resumeBGMIfNeeded() {
        guard isSoundEnabled else { return }
        bgmPlayer?.play()

    }
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil

    }
    func toggleSound() { isSoundEnabled.toggle() }

    func playShoot() { playSFX(named: shootFx) }
    func playExplosion() { playSFX(named: boomFx) }
    func playGameOver() { playSFX(named: overFx) }
    func playGameWin() { playSFX(named: winFx) }
    func willEnterBackground() {
        wasBgmPlayingBeforeBackground = bgmPlayer?.isPlaying == true
        if wasBgmPlayingBeforeBackground {
            pauseBGM()
            pausedByApp = true
        } else {
            pausedByApp = false
        }

    }

    func didEnterForeground() {

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {

        }

        guard isSoundEnabled else {

            return
        }

        if pausedByApp {
            pausedByApp = false
            if let p = bgmPlayer {
                p.play()

            } else {
                startBGM()

            }
        } else {

        }
    }

    private func playSFX(named name: String) {
        guard isSoundEnabled else { return }
        if let p = sfxPlayers[name] {
            p.currentTime = 0
            p.play()
        } else if let p = loadPlayer(file: name) {
            sfxPlayers[name] = p
            p.play()
        }
    }

    private func loadPlayer(file: String) -> AVAudioPlayer? {
        let base = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: base, withExtension: ext)
        else {

            return nil
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()

            return p
        } catch {

            return nil
        }
    }
}
