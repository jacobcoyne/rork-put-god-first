import SwiftUI

struct DevotionalReadingView: View {
    let devotional: Devotional
    let verse: DailyVerse
    var onDismiss: (() -> Void)? = nil
    let onComplete: () -> Void
    @State private var appear: Bool = false
    @State private var showShareSheet: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            ZStack {
                                LinearGradient(
                                    colors: [Theme.devotionalRose.opacity(0.5), Theme.icePurple.opacity(0.3), Theme.devotionalRoseDark.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )

                                RadialGradient(
                                    colors: [.white.opacity(isDark ? 0.08 : 0.2), .clear],
                                    center: .top,
                                    startRadius: 20,
                                    endRadius: 200
                                )

                                VStack(spacing: 0) {
                                    Spacer()
                                    LinearGradient(
                                        colors: [.clear, Color(.systemBackground).opacity(0.6), Color(.systemBackground)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 120)
                                }
                            }
                            .frame(height: 280)

                            HStack {
                                Button {
                                    showShareSheet = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(.ultraThinMaterial))
                                }
                                Spacer()
                                Button {
                                    (onDismiss ?? onComplete)()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(.ultraThinMaterial))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 60)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 11))
                                    Text("\(devotional.readingTimeMinutes) min read")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Theme.textSecondary)

                                Text(devotional.title)
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)

                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.devotionalRose, Theme.devotionalRoseLight.opacity(0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 40, height: 3)
                                .clipShape(Capsule())
                                .opacity(appear ? 1 : 0)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 11))
                                    Text("Based on \(verse.reference)")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundStyle(Theme.verseGold)

                                Text("\u{201C}\(verse.text)\u{201D}")
                                    .font(.system(size: 16, weight: .regular, design: .serif))
                                    .foregroundStyle(Theme.textPrimary.opacity(0.8))
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("\u{2014} \(verse.reference)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Theme.verseGold.opacity(0.7))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.verseGold.opacity(isDark ? 0.05 : 0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(Theme.verseGold.opacity(0.12), lineWidth: 1)
                                    )
                            )
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 15)

                            Text(devotional.body)
                                .font(.system(size: 19, weight: .regular, design: .serif))
                                .foregroundStyle(Theme.textPrimary.opacity(0.9))
                                .lineSpacing(9)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        .padding(.bottom, 120)
                    }
                }

                VStack(spacing: 0) {
                    Button(action: onComplete) {
                        HStack(spacing: 10) {
                            Text("Continue to Prayer")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.prayerTeal, Theme.prayerTealDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.prayerTeal.opacity(0.35), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appear = true }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: "\(devotional.title)\n\n\(String(devotional.body.prefix(300)))...\n\nRead today\u{2019}s full devotional on God First \u{2728}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793")
        }
    }
}
