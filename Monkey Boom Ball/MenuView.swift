import SwiftUI

struct MenuView: View {
    var onPlay: () -> Void
    var onSettings: () -> Void
    var onInfo: () -> Void

    private let balanceKey = "candy_balance_v1"

    private var savedBalance: Int {
        UserDefaults.standard.integer(forKey: balanceKey)
    }

    var body: some View {
        ZStack {
            Image("app_bg_main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    ZStack {
                        Image("app_bg_balance")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)

                        Text("\(savedBalance)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.init(hex: "FFC844"))
                            .offset(y: -2)
                            .offset(x: 10)
                    }
                }

                HStack(spacing: 40) {

                    Image("app_ic_logo-1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 320)

                    VStack {
                        Button {
                            onPlay()
                        } label: {
                            Image("app_btn_menu03")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 260, height: 80)
                        }

                        Button {
                            onSettings()
                        } label: {
                            Image("app_btn_menu02")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 56)
                        }

                        Button {
                            onInfo()
                        } label: {
                            Image("app_btn_menu01")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 56)
                        }
                    }

                }
            }

        }

    }

}
