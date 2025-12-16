import SwiftUI

struct MenuView: View {
    var onPlay: () -> Void
    var onSettings: () -> Void
    var onInfo: () -> Void
    var onWheel: () -> Void
    
    private let balanceKey = "candy_balance_v1"

    private var savedBalance: Int {
        let value = UserDefaults.standard.integer(forKey: balanceKey)
        if value == 0 {
            UserDefaults.standard.set(2000, forKey: balanceKey)
            return 2000
        }
        return value
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
                .padding(.top)
                
                Spacer()

                HStack(spacing: 40) {

                    Image("app_ic_logo-1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 260)

                    VStack {
                        Button {
                            onPlay()
                        } label: {
                            Image("app_btn_menu03")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 260, height: 80)
                        }
                        
                        HStack{
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
    
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex: "301D73"), location: 0.0),
                                .init(color: Color(hex: "5B37D9"), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
                    .frame(height: 50)
                
                    .overlay(
                        Button {
                            onWheel()
                        } label: {
                            Image("app_btn_wheel")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 65)
                        }
                        .offset(y: -20)
                    )
                  
            }

        }

    }

}
#Preview("MenuView") {
    MenuView(
        onPlay: {},
        onSettings: {},
        onInfo: {},
        onWheel: {}
    )
}
