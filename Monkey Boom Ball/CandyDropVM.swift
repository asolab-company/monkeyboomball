import Combine
import SwiftUI

enum CandyAssets {
    static let topPipe = "app_ic_tube-1"
    static let candies = [
        "app_ic_ball", "app_ic_ball-1", "app_ic_ball-2", "app_ic_ball-3",
        "app_ic_ball-4",
    ]
    static let bucketHead = "app_ic_vedro"
    static let bucketBase = "app_ic_tube"
}

struct Candy: Identifiable {
    let id = UUID()
    let sprite: String
    var pos: CGPoint
    var vel: CGPoint
    var isDropping: Bool = false
    var alive: Bool = true
}

struct Bucket: Identifiable {
    let id = UUID()
    var x: CGFloat
    var multiplier: Double
    var width: CGFloat
    var baseHeight: CGFloat
}

struct ExplosionFx: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var frame: Int = 1
}

struct WinFloat: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var text: String
    var opacity: Double = 1
    var dy: CGFloat = 0
}

final class CandyDropVM: ObservableObject {
    private let balanceKey = "candy_balance_v1"

    @Published var balance: Int = 5_000 {
        didSet { UserDefaults.standard.set(balance, forKey: balanceKey) }
    }
    @Published var bonusVisible: Bool = false

    private let betSteps: [Int] = [10, 50, 100, 200, 500, 1_000, 5_000]
    @Published private(set) var betIndex: Int = 2
    var bet: Int { betSteps[betIndex] }

    var canDrop: Bool { balance >= bet }

    @Published var currentCandy: Candy?
    @Published var droppingCandies: [Candy] = []
    @Published var buckets: [Bucket] = []

    @Published var explosions: [ExplosionFx] = []
    @Published var wins: [WinFloat] = []

    @Published var playSize: CGSize = .zero
    private var safeInsets: EdgeInsets = .init()

    let bucketHeadHeight: CGFloat = 70

    private let gravity: CGFloat = 1100
    private let topY: CGFloat = 100
    private var horizontalSpeed: CGFloat = 120

    private var timer: AnyCancellable?
    private var lastT: TimeInterval = CACurrentMediaTime()

    private var dropsCountForShuffle = Int.random(in: 10...20)
    private var totalDrops = 0
    @Published var lastWinAmount: Int = 0

    func configure(size: CGSize, safeInsets: EdgeInsets = .init()) {

        if let saved = UserDefaults.standard.object(forKey: balanceKey) as? Int
        {
            balance = saved
        } else {

            UserDefaults.standard.set(balance, forKey: balanceKey)
        }

        playSize = size
        self.safeInsets = safeInsets
        if buckets.isEmpty { layoutBuckets() }
        if currentCandy == nil { spawnNewCandy() }
        startLoop()
    }

    func startLoop() {
        timer?.cancel()
        lastT = CACurrentMediaTime()
        timer = Timer.publish(every: 1 / 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func candyBoundsX() -> (minX: CGFloat, maxX: CGFloat) {
        let sideInset = max(safeInsets.leading, safeInsets.trailing)
        let pad: CGFloat = sideInset + 36
        let minX = pad
        let maxX = max(pad, playSize.width - pad)
        return (minX, maxX)
    }

    private func layoutBuckets() {
        let count = 8
        let sideInset = max(safeInsets.leading, safeInsets.trailing)
        let sidePad: CGFloat = sideInset + 12
        let usable = max(1, playSize.width - sidePad * 2)
        let step = usable / CGFloat(count - 1)

        let topWidth = min(110, max(72, step * 0.82))

        let minH = playSize.height * 0.22
        let maxH = playSize.height * 0.30

        let multipliers: [Double] = [0.5, 1.0, 2.0, 1.5, 3.0, 0.5, 2.0, 1.0]
            .shuffled()

        buckets = (0..<count).map { i in
            Bucket(
                x: sidePad + CGFloat(i) * step,
                multiplier: multipliers[i % multipliers.count],
                width: topWidth,
                baseHeight: CGFloat.random(in: minH...maxH)
            )
        }
    }

    private func maybeShuffleBuckets() {
        guard totalDrops >= dropsCountForShuffle else { return }
        totalDrops = 0
        dropsCountForShuffle = Int.random(in: 10...20)

        let xs = buckets.map { $0.x }.shuffled()
        let mults = buckets.map { $0.multiplier }.shuffled()
        for i in buckets.indices {
            buckets[i].x = xs[i]
            buckets[i].multiplier = mults[i]

        }
    }

    private func spawnNewCandy() {
        let sprite = CandyAssets.candies.randomElement() ?? "app_ic_ball"
        let bounds = candyBoundsX()
        let x = CGFloat.random(in: bounds.minX...bounds.maxX)
        horizontalSpeed = CGFloat.random(in: 80...160)
        currentCandy = Candy(
            sprite: sprite,
            pos: CGPoint(x: x, y: topY),
            vel: CGPoint(
                x: Bool.random() ? horizontalSpeed : -horizontalSpeed,
                y: 0
            ),
            isDropping: false,
            alive: true
        )
    }

    func increaseBet() { betIndex = min(betIndex + 1, betSteps.count - 1) }
    func decreaseBet() { betIndex = max(betIndex - 1, 0) }

    func pressDrop() {
        guard canDrop else { return }
        guard var c = currentCandy, c.alive, !c.isDropping else { return }

        c.isDropping = true
        c.vel = .zero
        droppingCandies.append(c)

        currentCandy = nil
        spawnNewCandy()

        totalDrops += 1
        maybeShuffleBuckets()
        MusicManager.shared.playShoot()
    }

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = CGFloat(now - lastT)
        lastT = now

        if var c = currentCandy {
            let bounds = candyBoundsX()
            c.pos.x += c.vel.x * dt
            if c.pos.x < bounds.minX {
                c.pos.x = bounds.minX
                c.vel.x = abs(c.vel.x)
            }
            if c.pos.x > bounds.maxX {
                c.pos.x = bounds.maxX
                c.vel.x = -abs(c.vel.x)
            }
            currentCandy = c
        }

        for i in droppingCandies.indices {
            droppingCandies[i].vel.y += gravity * dt
            droppingCandies[i].pos.y += droppingCandies[i].vel.y * dt
        }

        resolveDrops()
        advanceFX(dt: dt)
    }

    private func resolveDrops() {
        guard !buckets.isEmpty else { return }
        var toRemove: Set<UUID> = []

        for cand in droppingCandies {
            if let (bucket, mouthCenterY) = bucketHit(for: cand) {

                MusicManager.shared.playGameWin()
                let win = Int(Double(bet) * bucket.multiplier)
                lastWinAmount = win
                balance += (win - bet)

                wins.append(
                    WinFloat(
                        pos: CGPoint(x: bucket.x, y: mouthCenterY + 10),
                        text: "+\(win)"
                    )
                )
                toRemove.insert(cand.id)
                continue
            }

            if cand.pos.y > playSize.height + 60 {
                MusicManager.shared.playExplosion()
                balance -= bet
                if balance < 20 {
                    balance += 100
                    triggerBonusFlash()

                }
                spawnExplosion(
                    at: CGPoint(x: cand.pos.x, y: playSize.height - 40)
                )
                toRemove.insert(cand.id)
            }
        }

        if !toRemove.isEmpty {
            droppingCandies.removeAll { toRemove.contains($0.id) }
        }
    }

    private func bucketHit(for candy: Candy) -> (Bucket, CGFloat)? {
        let bottomY = playSize.height
        let r: CGFloat = 30
        let toleranceY: CGFloat = 28

        for b in buckets {
            let mouthCenterY = bottomY - b.baseHeight - bucketHeadHeight / 2
            guard abs(candy.pos.y - mouthCenterY) < toleranceY else { continue }
            let half = b.width * 0.5
            let insideX =
                candy.pos.x > (b.x - half + r * 0.3)
                && candy.pos.x < (b.x + half - r * 0.3)
            if insideX { return (b, mouthCenterY) }
        }
        return nil
    }

    private func spawnExplosion(at pos: CGPoint) {
        var ex = ExplosionFx(pos: pos, frame: 1)
        let id = ex.id
        explosions.append(ex)

        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) {
            [weak self] t in
            guard let self else {
                t.invalidate()
                return
            }
            guard let idx = self.explosions.firstIndex(where: { $0.id == id })
            else {
                t.invalidate()
                return
            }
            var e = self.explosions[idx]
            e.frame += 1
            if e.frame > 8 {
                self.explosions.remove(at: idx)
                t.invalidate()
            } else {
                self.explosions[idx] = e
            }
        }
    }

    private func advanceFX(dt: CGFloat) {
        for i in wins.indices {
            wins[i].dy -= 40 * dt
            wins[i].opacity -= 0.7 * dt
        }
        wins.removeAll { $0.opacity <= 0 }
    }

    private func triggerBonusFlash() {
        MusicManager.shared.playGameOver()
        bonusVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.bonusVisible = false
        }
    }
}
