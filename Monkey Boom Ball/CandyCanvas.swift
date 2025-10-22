import SwiftUI

struct CandyCanvas: View {
    @ObservedObject var vm: CandyDropVM

    var body: some View {
        GeometryReader { geo in

            let bottomY = geo.size.height
            let headH: CGFloat = vm.bucketHeadHeight
            let insets = geo.safeAreaInsets

            ZStack {

                let pipeW = max(
                    1,
                    geo.size.width - (insets.leading + insets.trailing)
                )
                Image(CandyAssets.topPipe)
                    .resizable()
                    .scaledToFill()
                    .frame(width: pipeW, height: 40)
                    .position(x: geo.size.width / 2, y: 100)
                    .allowsHitTesting(false)

                if let c = vm.currentCandy {
                    Image(c.sprite)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .position(c.pos)
                        .shadow(radius: 4)
                }

                ForEach(vm.droppingCandies) { c in
                    Image(c.sprite)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .position(c.pos)
                }

                ForEach(vm.buckets) { b in
                    let baseCenterY = bottomY - b.baseHeight / 2
                    Image(CandyAssets.bucketBase)
                        .resizable()
                        .frame(width: b.width * 0.4, height: b.baseHeight)
                        .position(x: b.x, y: baseCenterY)
                        .allowsHitTesting(false)
                }

                ForEach(vm.buckets) { b in

                    let headCenterY = bottomY - b.baseHeight - headH / 2
                    ZStack {
                        Image(CandyAssets.bucketHead)
                            .resizable()
                            .scaledToFit()
                            .frame(width: b.width, height: headH)

                        Text("x\(trim(b.multiplier))")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white.opacity(0.5))
                            .shadow(radius: 2)
                            .offset(y: 8)
                    }
                    .position(x: b.x + 1, y: headCenterY + 15)
                    .allowsHitTesting(false)
                }

                ForEach(vm.explosions) { ex in
                    Image("app_anim_bang\(ex.frame)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .position(ex.pos)
                        .transition(.opacity)
                }

                ForEach(vm.wins) { w in
                    Text(w.text)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.yellow)
                        .shadow(radius: 4)
                        .opacity(w.opacity)
                        .position(x: w.pos.x, y: w.pos.y + w.dy)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                vm.configure(size: geo.size, safeInsets: insets)
            }
            .onChange(of: geo.size) { newSize in
                vm.configure(size: newSize, safeInsets: insets)
            }
        }
    }

    private func trim(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v)).0" : String(v)
    }
}
