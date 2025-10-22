import SwiftUI

struct GameView: View {
    @StateObject private var vm = CandyDropVM()
    var onBack: () -> Void
    var body: some View {
        ZStack {
            Image("app_bg_main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            CandyCanvas(vm: vm).ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        onBack()
                    }) {
                        Image("app_btn_home")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32)
                            .padding(.leading, 100)
                    }
                    Spacer()
                    ZStack {
                        Image("app_bg_balance")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)

                        Text("\(vm.balance)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.init(hex: "FFC844"))
                            .offset(y: -2)
                            .offset(x: 10)
                    }

                    Spacer()

                    ZStack {
                        Image("app_bg_balance2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)

                        Text("\(vm.lastWinAmount)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.init(hex: "FFC844"))
                            .offset(y: -2)
                            .offset(x: 19)
                    }
                    Spacer()
                }

                Spacer()

            }
            .padding(.top)

            VStack {

                Spacer()
                ZStack {

                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.black.opacity(0.43))
                        .ignoresSafeArea(edges: .bottom)
                        .frame(width: 500, height: 70)
                    HStack {
                        Button(action: {
                            vm.increaseBet()
                        }) {
                            Image("app_btn_arrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32)
                        }

                        ZStack {
                            Image("app_bg_balance")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)

                            Text("\(vm.bet)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.init(hex: "FFC844"))
                                .offset(y: -2)
                                .offset(x: 10)
                        }
                        Button(action: {
                            vm.decreaseBet()
                        }) {
                            Image("app_btn_arrow2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32)
                        }

                        Button(action: {
                            vm.pressDrop()
                        }) {
                            Image("app_btn_drop")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160)
                                .opacity(vm.canDrop ? 1.0 : 0.5)
                        }
                        .buttonStyle(.plain)
                        .disabled(!vm.canDrop)
                    }

                }

            }

            Image("app_ic_bonus")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .opacity(vm.bonusVisible ? 1 : 0)
                .scaleEffect(vm.bonusVisible ? 1.0 : 0.85)
                .animation(.easeOut(duration: 0.18), value: vm.bonusVisible)
                .animation(
                    .easeIn(duration: 0.15).delay(0.75),
                    value: vm.bonusVisible
                )

        }

    }

}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
