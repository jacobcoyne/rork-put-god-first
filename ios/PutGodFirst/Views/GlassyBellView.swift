import SwiftUI

struct GlassyBellView: View {
    @State private var orbFloat: CGFloat = 0
    @State private var bellSwing: Double = 0
    @State private var rotationY: Double = 0

    private let bellRed = Color(red: 0.88, green: 0.18, blue: 0.18)
    private let bellDark = Color(red: 0.55, green: 0.08, blue: 0.1)
    private let bellLight = Color(red: 1.0, green: 0.45, blue: 0.4)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            bellRed.opacity(0.25),
                            bellRed.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 15,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            ZStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [bellDark, bellDark.opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blur(radius: 6)
                    .offset(x: 2, y: 4)
                    .opacity(0.5)

                Image(systemName: "bell.fill")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                bellLight,
                                bellRed,
                                bellDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: bellRed.opacity(0.4), radius: 10, y: 4)

                Image(systemName: "bell.fill")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .rotationEffect(.degrees(bellSwing))
            .offset(y: orbFloat)
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                rotationY = 12
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                orbFloat = -6
            }
            startBellSwing()
        }
    }

    private func startBellSwing() {
        func cycle() {
            withAnimation(.easeInOut(duration: 0.15)) { bellSwing = 12 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.13)) { bellSwing = -9 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeInOut(duration: 0.12)) { bellSwing = 6 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
                withAnimation(.easeInOut(duration: 0.11)) { bellSwing = -3 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                withAnimation(.easeInOut(duration: 0.15)) { bellSwing = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                cycle()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            cycle()
        }
    }
}
