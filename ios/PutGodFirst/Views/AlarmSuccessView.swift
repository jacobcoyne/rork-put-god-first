import SwiftUI

struct AlarmSuccessView: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @State private var confettiVisible: Bool = false
    @State private var sunScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var confettiPieces: [ConfettiPiece] = (0..<40).map { _ in
        ConfettiPiece(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: -0.3...0.0),
            size: CGFloat.random(in: 4...10),
            color: [Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan, .indigo].randomElement()!,
            rotation: Double.random(in: 0...360),
            velocity: CGFloat.random(in: 0.3...0.8)
        )
    }
    @State private var confettiOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.03, blue: 0.12)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.25, green: 0.2, blue: 0.08).opacity(0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 250
            )
            .ignoresSafeArea()

            confettiLayer

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.35, blue: 0.2),
                                    Color(red: 0.2, green: 0.18, blue: 0.12)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Theme.dawnGold.opacity(0.3), radius: 30)

                    Text("☀️")
                        .font(.system(size: 64))
                }
                .scaleEffect(sunScale)

                Spacer().frame(height: 32)

                VStack(spacing: 8) {
                    Text("Alarm turned off!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Great job putting God first this morning")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .opacity(textOpacity)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        alarmVM.dismissAlarm()
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 28))
                }
                .opacity(buttonOpacity)
                .padding(.horizontal, 24)

                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                sunScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                buttonOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.3)) {
                confettiVisible = true
            }
            withAnimation(.linear(duration: 3.0)) {
                confettiOffset = 800
            }
        }
        .sensoryFeedback(.success, trigger: confettiVisible)
    }

    private var confettiLayer: some View {
        GeometryReader { geo in
            ForEach(confettiPieces.indices, id: \.self) { i in
                let piece = confettiPieces[i]
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 1.5)
                    .rotationEffect(.degrees(piece.rotation + confettiOffset * 0.3))
                    .position(
                        x: piece.x * geo.size.width,
                        y: piece.y * geo.size.height + confettiOffset * piece.velocity
                    )
                    .opacity(confettiVisible ? (confettiOffset < 600 ? 1.0 : max(0.0, 1.0 - Double(confettiOffset - 600) / 200.0)) : 0.0)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
    let velocity: CGFloat
}
