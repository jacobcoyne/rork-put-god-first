import SwiftUI

struct VerseExpandedSheet: View {
    let verse: DailyVerse
    @Environment(\.dismiss) private var dismiss
    @State private var appear: Bool = false
    @State private var showShareSheet: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 12))
                            Text("VERSE OF THE DAY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                        }
                        .foregroundStyle(Theme.verseGold)

                        Text(verse.reference)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.verseGold, Theme.dawnAmber.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 40, height: 4)
                        .clipShape(Capsule())
                        .opacity(appear ? 1 : 0)

                    Text("\u{201C}\(verse.text)\u{201D}")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(12)
                        .tracking(0.3)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 15)

                    Text("\u{2014} \(verse.reference) (\(verse.translation))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.verseGold)
                        .opacity(appear ? 1 : 0)

                    Button {
                        showShareSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15))
                            Text("Share This Verse")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.verseGold, Theme.dawnAmber],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                    }
                    .opacity(appear ? 1 : 0)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.verseGold)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: "\u{201C}\(verse.text)\u{201D}\n\n\u{2014} \(verse.reference)\n\nShared from God First \u{2728}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
    }
}
