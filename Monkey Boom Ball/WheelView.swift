import SwiftUI
import UnityAds

final class UnityRewardedAds: NSObject, ObservableObject {
    @Published private(set) var isReady: Bool = false  

    private var gameId: String = ""
    private var placementId: String = ""
    private var testMode: Bool = true

    private var onCompleted: (() -> Void)?

    func configure(gameId: String, placementId: String, testMode: Bool) {
        self.gameId = gameId
        self.placementId = placementId
        self.testMode = testMode
    }

    func initializeIfNeeded() {
        guard !gameId.isEmpty, !placementId.isEmpty else { return }
        if UnityAds.isInitialized() {
            if !isReady { load() }
            return
        }
        UnityAds.initialize(gameId, testMode: testMode, initializationDelegate: self)
    }

    func refreshReady() {
        
        
        guard !placementId.isEmpty else { return }
        if UnityAds.isInitialized() && !isReady {
            load()
        }
    }

    func load() {
        guard UnityAds.isInitialized(), !placementId.isEmpty else { return }
        UnityAds.load(placementId, options: UADSLoadOptions(), loadDelegate: self)
    }

    func show(from viewController: UIViewController, onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
        guard isReady else {
            self.onCompleted = nil
            
            load()
            return
        }
        UnityAds.show(viewController, placementId: placementId, showDelegate: self)
    }
}

extension UnityRewardedAds: UnityAdsInitializationDelegate {
    func initializationComplete() {
        DispatchQueue.main.async {
            self.isReady = false
            self.load()
        }
    }

    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        DispatchQueue.main.async { self.isReady = false }
    }
}

extension UnityRewardedAds: UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        DispatchQueue.main.async {
            if placementId == self.placementId {
                self.isReady = true
            }
        }
    }

    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        DispatchQueue.main.async {
            if placementId == self.placementId {
                self.isReady = false
            }
        }
    }
}

extension UnityRewardedAds: UnityAdsShowDelegate {
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        DispatchQueue.main.async {
            
            self.isReady = false

            if state == .showCompletionStateCompleted {
                self.onCompleted?()
            }

            self.onCompleted = nil
            self.load()
        }
    }

    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        DispatchQueue.main.async {
            self.isReady = false
            self.onCompleted = nil
            self.load()
        }
    }

    func unityAdsShowStart(_ placementId: String) { }
    func unityAdsShowClick(_ placementId: String) { }
}

struct WheelView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("candy_balance_v1") private var savedBalance: Int = 2000

    @EnvironmentObject private var rewardedAds: UnityRewardedAds

    @State private var showDoubleOffer: Bool = false
    @State private var lastSpinReward: Int = 0

    
    @AppStorage("wheel_cooldown_end") private var cooldownEndTimestamp: Double = 0

    @State private var now = Date()
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var wheelRotation: Double = 0
    @State private var isSpinning = false

    private var cooldownEndDate: Date {
        Date(timeIntervalSince1970: cooldownEndTimestamp)
    }

    private var isCooldownActive: Bool {
        cooldownEndTimestamp > 0 && now < cooldownEndDate
    }

    private var remainingSeconds: Int {
        max(0, Int(cooldownEndDate.timeIntervalSince(now)))
    }

    private let segmentsCount: Int = 12
    private var sectorSize: Double { 360.0 / Double(segmentsCount) }

    private func normalizedAngle(_ a: Double) -> Double {
        var v = a.truncatingRemainder(dividingBy: 360)
        if v < 0 { v += 360 }
        return v
    }

    
    
    
    
    
    private func sectorNumber(fromRotation rotation: Double) -> Int {
        let a = normalizedAngle(rotation)
        let rawIndex = Int((a / sectorSize).rounded()) % segmentsCount  
        let sectorIndex = (segmentsCount - rawIndex) % segmentsCount
        return sectorIndex + 1
    }

    private func rewardForSector(_ sector: Int) -> Int {
        switch sector {
        case 1: return 100
        case 2: return 200
        case 3: return 50
        case 4: return 100
        case 5: return 75
        case 6: return 200
        case 7: return 50
        case 8: return 100
        case 9: return 75
        case 10: return 200
        case 11: return 0   
        case 12: return 75
        default: return 0
        }
    }

    private func applyReward(_ points: Int) {
        lastSpinReward = points
        guard points > 0 else { return }
        savedBalance += points
    }

    private var shouldDimWheel: Bool {
        isCooldownActive
    }

    private func formattedCountdown(_ totalSeconds: Int) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func startCooldown12h() {
        cooldownEndTimestamp = Date().addingTimeInterval(12 * 60 * 60).timeIntervalSince1970
    }

    private func spinWheel() {
        guard !isSpinning, !isCooldownActive else { return }

        isSpinning = true

        
        let extra = Double(Int.random(in: 0..<360))
        let turns = Double(Int.random(in: 6...10)) * 360.0
        let target = wheelRotation + turns + extra

        withAnimation(.easeOut(duration: 3.0)) {
            wheelRotation = target
        }

        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            let angle = normalizedAngle(wheelRotation)
            let rawIndex = Int((angle / sectorSize).rounded()) % segmentsCount
            let snappedAngle = Double(rawIndex) * sectorSize
            let delta = snappedAngle - angle

            withAnimation(.easeOut(duration: 0.25)) {
                wheelRotation += delta
            }

            
            let sector = sectorNumber(fromRotation: wheelRotation)
            let reward = rewardForSector(sector)

            isSpinning = false

            let delay = Double.random(in: 1.0...2.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                applyReward(reward)

                
                if sector != 11 {
                    startCooldown12h()

                    
                    if reward > 0 && rewardedAds.isReady {
                        showDoubleOffer = true
                    } else {
                        showDoubleOffer = false
                    }
                } else {
                    showDoubleOffer = false
                }
            }
        }
    }

    var onBack: () -> Void

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

                    ZStack {
                        Image("app_bg_balance")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)

                        Text("\(savedBalance)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "FFC844"))
                            .offset(x: 10, y: -2)
                    }

                    Spacer()
                    
                    Button {
                      
                    } label: {
                        Image("app_btn_home")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                            .padding(.trailing, 100)
                    }
                    .opacity(0)
                }

                Spacer()
                
                HStack{
                    Image("app_ic_monkey")
                        .resizable()
                        .scaledToFit()
                    ZStack {
                        Image("game_ic_wheel")
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(wheelRotation))
                            .overlay(
                                Circle()
                                    .fill(Color.black.opacity(shouldDimWheel ? 0.6 : 0))
                            )
                            .animation(.easeInOut(duration: 0.25), value: shouldDimWheel)

                        if !isCooldownActive {
                            Button {
                                spinWheel()
                            } label: {
                                Image("app_btn_spin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                            }
                            .buttonStyle(.plain)
                            .opacity(isSpinning ? 0 : 1)
                            .disabled(isSpinning)
                        }

                        VStack {
                            Image("game_ic_wheel_top")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .offset(y: -8)

                            Spacer()
                        }

                        if isCooldownActive {
                            VStack {
                                Spacer()

                                ZStack {
                                    Image("app_bg_timer")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 60)

                                    Text(formattedCountdown(remainingSeconds))
                                        .font(.system(size: 24, weight: .heavy))
                                        .foregroundColor(Color(hex: "FFBD0E"))
                                        .offset(y: -3)
                                }
                                .offset(y: 8)
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: isCooldownActive)
                
                }
            }
            .padding(.vertical)
            .onReceive(tick) { now = $0 }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { now = Date() }
            }
            .onAppear {
                if savedBalance == 0 {
                    savedBalance = 2000
                }
            }
            
            if showDoubleOffer {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "000000"), location: 0.0),
                            .init(color: Color(hex: "232380"), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .opacity(0.7)
                    .ignoresSafeArea()

                    ZStack {
                        Image("bg_double")
                            .resizable()
                            .scaledToFit()
                    }
                    .overlay(alignment: .topTrailing) {
                        Button {
                            showDoubleOffer = false
                        } label: {
                            Image("app_btn_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    .overlay(alignment: .bottom) {
                        Button {
                            
                            guard let top = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .flatMap({ $0.windows })
                                .first(where: { $0.isKeyWindow })?.rootViewController else {
                                return
                            }

                            rewardedAds.show(from: top) {
                                if lastSpinReward > 0 {
                                    savedBalance += lastSpinReward
                                }
                                showDoubleOffer = false
                            }
                        } label: {
                            Image("app_btn_watch")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                        }
                        .buttonStyle(.plain)
                        .disabled(!rewardedAds.isReady)
                        .opacity(rewardedAds.isReady ? 1 : 0.5)
                        .offset(y: 40)
                    }
                    .padding(50)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: showDoubleOffer)
            }
            
        }
    }
}

#Preview("WheelView") {
    WheelView(onBack: {})
        .environmentObject(UnityRewardedAds())
}
