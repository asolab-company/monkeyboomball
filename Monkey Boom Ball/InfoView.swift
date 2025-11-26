import SwiftUI

struct InfoView: View {
    var onBack: () -> Void
    var body: some View {
        ZStack {
            Image("app_bg_main2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
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

                Image("app_ic_info")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)

            }
            .padding(.top)

        }

    }

}
