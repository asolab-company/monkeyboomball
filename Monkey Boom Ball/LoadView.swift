import SwiftUI

struct LoadView: View {
    var onFinish: () -> Void
    @State private var logoVisible = false

    var body: some View {
        ZStack {
            Image("app_bg_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Image("app_ic_logo")
                .resizable()
                .scaledToFit()
                .opacity(logoVisible ? 1 : 0)
                .animation(.easeIn(duration: 1), value: logoVisible)
        }
        .onAppear {

            logoVisible = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
    }
}

#Preview {
    LoadView(onFinish: {})
}
