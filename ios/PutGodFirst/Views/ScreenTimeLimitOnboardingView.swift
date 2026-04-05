import SwiftUI
import FamilyControls

struct ScreenTimeLimitOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entranceAnimation: Bool = false
    @State private var pulseGlow: Bool = false
    var onEnable: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.12),
                    Color(red: 0.08, green: 0.04, blue: 0.22),
                    Color(red: 0.04, green: 0.03, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                headerIcon
                    .opacity(entranceAnimation ? 1 : 0)
                    .scaleEffect(entranceAnimation ? 1 : 0.5)

                Spacer().frame(height: 28)

                VStack(spacing: 10) {
                    Text("Set Screen Time Limits?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Limit daily usage on your favorite apps.\nWhen time's up, complete a quick faith challenge\nto keep using them.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .opacity(entranceAnimation ? 1 : 0)
                .offset(y: entranceAnimation ? 0 : 20)

                Spacer().frame(height: 36)

                VStack(spacing: 14) {
                    featureRow(
                        icon: "clock.fill",
                        text: "Choose a daily time limit per app",
                        color: Theme.iceBlue,
                        delay: 0.15
                    )
                    featureRow(
                        icon: "shield.fill",
                        text: "Apps lock when your limit is reached",
                        color: Theme.coral,
                        delay: 0.25
                    )
                    featureRow(
                        icon: "book.fill",
                        text: "Recite scripture or open your Bible to unlock",
                        color: Theme.icePurple,
                        delay: 0.35
                    )
                    featureRow(
                        icon: "arrow.counterclockwise",
                        text: "Resets every day automatically",
                        color: Theme.successEmerald,
                        delay: 0.45
                    )
                }
                .padding(.horizontal, 28)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                        onEnable()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 16, weight: .bold))
                            Text("Enable Screen Time Limits")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.dawnGold, Theme.dawnAmber],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.dawnAmber.opacity(0.4), radius: 16, y: 6)
                    }

                    Button {
                        onSkip()
                    } label: {
                        Text("Maybe Later")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .padding(.horizontal, 28)
                .opacity(entranceAnimation ? 1 : 0)
                .offset(y: entranceAnimation ? 0 : 30)

                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                entranceAnimation = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.dawnAmber.opacity(pulseGlow ? 0.25 : 0.1),
                            Theme.dawnGold.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(pulseGlow ? 1.08 : 0.95)

            Image(systemName: "hourglass")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.dawnGold, Theme.dawnAmber],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Theme.dawnGold.opacity(0.6), radius: 20)
        }
    }

    private func featureRow(icon: String, text: String, color: Color, delay: Double) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .opacity(entranceAnimation ? 1 : 0)
        .offset(x: entranceAnimation ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(delay), value: entranceAnimation)
    }
}
