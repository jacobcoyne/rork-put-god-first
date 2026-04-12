import SwiftUI

struct TimeLimitChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showScriptureUnlock: Bool = false
    @State private var showBiblePhoto: Bool = false
    @State private var entranceAnimation: Bool = false
    @State private var emojiPulse: Bool = false
    @State private var shimmer: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var onUnlocked: (() -> Void)?

    private var randomMotivation: ShieldMessage {
        ShieldMessage.allMessages.randomElement() ?? ShieldMessage.allMessages[0]
    }

    @State private var currentMessage: ShieldMessage = ShieldMessage.allMessages[0]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)

                        emojiHeader
                            .opacity(entranceAnimation ? 1 : 0)
                            .scaleEffect(entranceAnimation ? 1 : 0.3)

                        Spacer().frame(height: 24)

                        titleSection
                            .opacity(entranceAnimation ? 1 : 0)
                            .offset(y: entranceAnimation ? 0 : 20)

                        Spacer().frame(height: 12)

                        motivationalQuip
                            .opacity(entranceAnimation ? 1 : 0)
                            .offset(y: entranceAnimation ? 0 : 15)

                        Spacer().frame(height: 32)

                        statsCard
                            .opacity(entranceAnimation ? 1 : 0)
                            .offset(y: entranceAnimation ? 0 : 25)

                        Spacer().frame(height: 24)

                        whyBlockedCard
                            .opacity(entranceAnimation ? 1 : 0)
                            .offset(y: entranceAnimation ? 0 : 25)

                        Spacer().frame(height: 28)

                        unlockSection
                            .opacity(entranceAnimation ? 1 : 0)
                            .offset(y: entranceAnimation ? 0 : 30)

                        Spacer().frame(height: 32)

                        closeButton
                            .opacity(entranceAnimation ? 1 : 0)

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                currentMessage = ShieldMessage.allMessages.randomElement() ?? ShieldMessage.allMessages[0]
                withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                    entranceAnimation = true
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    emojiPulse = true
                }
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    shimmer = true
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

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.16),
                    Color(red: 0.10, green: 0.05, blue: 0.25),
                    Color(red: 0.06, green: 0.04, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    Theme.icePurple.opacity(0.08),
                    .clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
        }
    }

    private var emojiHeader: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.icePurple.opacity(emojiPulse ? 0.18 : 0.06),
                            Theme.dawnAmber.opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 90
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(emojiPulse ? 1.08 : 0.92)

            Text(currentMessage.emoji)
                .font(.system(size: 72))
                .scaleEffect(emojiPulse ? 1.05 : 0.95)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text(currentMessage.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(currentMessage.subtitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
    }

    private var motivationalQuip: some View {
        Text(currentMessage.quip)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white.opacity(0.45))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(
                emoji: "⏱️",
                value: "\(ScreenTimeLimitService.shared.dailyLimitMinutes)m",
                label: "Daily Limit"
            )

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1, height: 44)

            statItem(
                emoji: "🛡️",
                value: "Active",
                label: "Shield Status"
            )

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1, height: 44)

            statItem(
                emoji: "🔥",
                value: "Today",
                label: "Blocked Since"
            )
        }
        .padding(.vertical, 18)
        .background(Color.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func statItem(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var whyBlockedCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("🚫")
                    .font(.system(size: 18))
                Text("Why am I seeing this?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 10) {
                infoRow(emoji: "📱", text: "You hit your daily screen time limit")
                infoRow(emoji: "🧠", text: "Your future self set this up to protect you")
                infoRow(emoji: "✝️", text: "Unlock by spending time in God's Word")
            }

            Divider()
                .overlay(.white.opacity(0.06))

            HStack(spacing: 6) {
                Text("💡")
                    .font(.system(size: 14))
                Text("This isn't punishment — it's protection. You chose this! 💪")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func infoRow(emoji: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 15))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var unlockSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 6) {
                Text("🔓")
                    .font(.system(size: 16))
                Text("Choose your unlock challenge")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.3)
            }

            Button {
                let gen = UIImpactFeedbackGenerator(style: .medium)
                gen.impactOccurred()
                showScriptureUnlock = true
            } label: {
                HStack(spacing: 14) {
                    Text("🎙️")
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Recite Scripture")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Read a verse out loud — flex that faith 🗣️")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.icePurple.opacity(0.6))
                }
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [Theme.icePurple.opacity(0.12), Theme.iceLavender.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Theme.icePurple.opacity(0.3), Theme.iceLavender.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }

            Button {
                let gen = UIImpactFeedbackGenerator(style: .medium)
                gen.impactOccurred()
                showBiblePhoto = true
            } label: {
                HStack(spacing: 14) {
                    Text("📖")
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Open Bible Photo")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Snap your Bible open — prove you in the Word 📸")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.dawnGold.opacity(0.6))
                }
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [Theme.dawnGold.opacity(0.1), Theme.dawnAmber.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Theme.dawnGold.opacity(0.25), Theme.dawnAmber.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.white.opacity(0.06))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

private struct ShieldMessage {
    let emoji: String
    let title: String
    let subtitle: String
    let quip: String

    static let allMessages: [ShieldMessage] = [
        ShieldMessage(
            emoji: "🛡️",
            title: "Apps Blocked",
            subtitle: "Your shield is up!",
            quip: "Doomscrolling tried to enter the chat.\nYour shield said nah. 😤"
        ),
        ShieldMessage(
            emoji: "⏰",
            title: "Time's Up!",
            subtitle: "Screen time limit reached",
            quip: "The apps can wait.\nYour peace of mind can't. 🕊️"
        ),
        ShieldMessage(
            emoji: "🚫",
            title: "Not Today,\nDoomscroll",
            subtitle: "You set boundaries. We enforce them.",
            quip: "Instagram was trying to steal your time.\nWe blocked that real quick. 💨"
        ),
        ShieldMessage(
            emoji: "🔒",
            title: "Shield Mode:\nActivated",
            subtitle: "Your apps are taking a nap",
            quip: "Your future self thanks you\nfor not opening TikTok rn. 🙏"
        ),
        ShieldMessage(
            emoji: "💪",
            title: "Stay Strong",
            subtitle: "Your screen time limit hit",
            quip: "You literally asked us to do this.\nSo here we are. No cap. 🧢"
        ),
        ShieldMessage(
            emoji: "🧘",
            title: "Touch Grass\nMoment",
            subtitle: "Screen time exceeded",
            quip: "Instead of scrolling, maybe go\noutside? Just a thought. 🌿"
        ),
        ShieldMessage(
            emoji: "⚔️",
            title: "Spiritual\nWarfare Mode",
            subtitle: "Your shield of faith is active",
            quip: "\"Put on the full armor of God\"\n— Ephesians 6:11 🛡️"
        ),
        ShieldMessage(
            emoji: "🏆",
            title: "Self-Control\nW",
            subtitle: "You're winning right now",
            quip: "Most people can't stop scrolling.\nYou're built different. Fr fr. 💯"
        ),
        ShieldMessage(
            emoji: "😤",
            title: "Nope.\nNot Happening.",
            subtitle: "Apps are locked down",
            quip: "We caught you trying to open\nthose apps again lol 👀"
        ),
        ShieldMessage(
            emoji: "🌅",
            title: "Go Read\nYour Bible",
            subtitle: "The Word > The Feed",
            quip: "Scrolling fills your time.\nScripture fills your soul. ✨"
        ),
    ]
}
