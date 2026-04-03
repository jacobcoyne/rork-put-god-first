import SwiftUI

struct DevotionalExpandedSheet: View {
    let devotional: Devotional
    let verse: DailyVerse
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var appear: Bool = false
    @State private var showShareSheet: Bool = false

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack {
                        LinearGradient(
                            colors: [Theme.devotionalRose.opacity(0.45), Theme.icePurple.opacity(0.25), Theme.devotionalRoseDark.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        RadialGradient(
                            colors: [.white.opacity(isDark ? 0.06 : 0.18), .clear],
                            center: .topTrailing,
                            startRadius: 10,
                            endRadius: 160
                        )

                        VStack(spacing: 0) {
                            Spacer()
                            LinearGradient(
                                colors: [.clear, Color(.systemBackground).opacity(0.7), Color(.systemBackground)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)
                        }
                    }
                    .frame(height: 220)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: "text.book.closed.fill")
                                        .font(.system(size: 11))
                                    Text("TODAY\u{2019}S DEVOTIONAL")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(1.0)
                                }
                                .foregroundStyle(Theme.devotionalRose)

                                Text(devotional.title)
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                        .clipped()

                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text("\(devotional.readingTimeMinutes) min read")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Theme.textSecondary)
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
                        .offset(y: appear ? 0 : 12)

                        Text(devotional.body)
                            .font(.system(size: 19, weight: .regular, design: .serif))
                            .foregroundStyle(Theme.textPrimary.opacity(0.92))
                            .lineSpacing(10)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 15)

                        Button {
                            showShareSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15))
                                Text("Share This Devotional")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Theme.devotionalRose, Theme.icePurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .shadow(color: Theme.devotionalRose.opacity(0.3), radius: 12, y: 4)
                        }
                        .opacity(appear ? 1 : 0)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.devotionalRose)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: "\(devotional.title)\n\n\(String(devotional.body.prefix(300)))...\n\nRead today\u{2019}s full devotional on God First \u{2728}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appear = true }
        }
    }
}
