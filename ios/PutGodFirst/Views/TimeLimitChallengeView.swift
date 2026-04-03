import SwiftUI

struct TimeLimitChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedChallenge: ChallengeType?
    @State private var showScriptureUnlock: Bool = false
    @State private var showBiblePhoto: Bool = false
    @State private var entranceAnimation: Bool = false
    @State private var cardPulse: Bool = false

    var onUnlocked: (() -> Void)?

    private enum ChallengeType: String, Identifiable {
        case scripture = "scripture"
        case biblePhoto = "biblePhoto"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.03, blue: 0.12),
                        Color(red: 0.08, green: 0.04, blue: 0.22),
                        Color(red: 0.04, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 20)

                    headerIcon
                        .opacity(entranceAnimation ? 1 : 0)
                        .scaleEffect(entranceAnimation ? 1 : 0.6)

                    Spacer().frame(height: 20)

                    VStack(spacing: 6) {
                        Text("Screen Time Exceeded")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Choose a challenge to unlock")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .multilineTextAlignment(.center)
                    .opacity(entranceAnimation ? 1 : 0)
                    .offset(y: entranceAnimation ? 0 : 20)

                    Spacer().frame(height: 32)

                    VStack(spacing: 16) {
                        challengeCard(
                            type: .scripture,
                            icon: "mic.fill",
                            title: "Recite Scripture",
                            subtitle: "Read a verse aloud to prove your devotion",
                            gradient: [Theme.icePurple, Theme.iceLavender],
                            delay: 0.2
                        )

                        challengeCard(
                            type: .biblePhoto,
                            icon: "camera.fill",
                            title: "Open Bible Photo",
                            subtitle: "Snap a photo of your open Bible",
                            gradient: [Theme.dawnGold, Theme.dawnAmber],
                            delay: 0.35
                        )
                    }
                    .padding(.horizontal, 4)

                    Spacer()

                    usageInfo
                        .opacity(entranceAnimation ? 1 : 0)

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    entranceAnimation = true
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    cardPulse = true
                }
            }
            .sheet(isPresented: $showScriptureUnlock) {
                ScriptureUnlockView {
                    ScreenTimeLimitService.shared.unlockWithChallenge()
                    onUnlocked?()
                    dismiss()
                }
            }
            .sheet(isPresented: $showBiblePhoto) {
                BiblePhotoUnlockView {
                    onUnlocked?()
                    dismiss()
                }
            }
        }
    }

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.dawnAmber.opacity(cardPulse ? 0.25 : 0.1),
                            Theme.icePurple.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
                .frame(width: 130, height: 130)
                .scaleEffect(cardPulse ? 1.05 : 0.95)

            ZStack {
                Image(systemName: "hourglass")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Theme.dawnGold.opacity(0.5), radius: 16)
            }
        }
    }

    private func challengeCard(
        type: ChallengeType,
        icon: String,
        title: String,
        subtitle: String,
        gradient: [Color],
        delay: Double
    ) -> some View {
        Button {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            switch type {
            case .scripture:
                showScriptureUnlock = true
            case .biblePhoto:
                showBiblePhoto = true
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(
                                LinearGradient(
                                    colors: gradient.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .opacity(entranceAnimation ? 1 : 0)
        .offset(y: entranceAnimation ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: entranceAnimation)
    }

    private var usageInfo: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.dawnAmber.opacity(0.6))
                Text("Daily limit: \(ScreenTimeLimitService.shared.dailyLimitMinutes) minutes")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Text("Complete a challenge to continue using your apps")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
    }
}
