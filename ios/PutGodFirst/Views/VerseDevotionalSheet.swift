import SwiftUI

struct VerseDevotionalSheet: View {
    @Bindable var viewModel: BibleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appearAnimation: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    verseQuote
                    
                    if viewModel.isGeneratingDevotional {
                        loadingState
                    } else {
                        devotionalContent
                        prayerContent
                        shareButton
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Devotional")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.logoBlue)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: shareText)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
    }

    private var verseQuote: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 12))
                Text("SELECTED PASSAGE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundStyle(Theme.logoBlue)

            Text("\u{201C}\(viewModel.selectedVerseText)\u{201D}")
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(6)

            Text("\u{2014} \(viewModel.selectedVerseReference) (\(viewModel.translationAbbreviation))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.logoBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.logoBlue.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.logoBlue.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.logoPurple)
                .scaleEffect(1.3)
            Text("Crafting your devotional...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Text("Reflecting on the Word")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var devotionalContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 12))
                Text("REFLECTION")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundStyle(Theme.logoPurple)

            Text(viewModel.generatedTitle)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text(viewModel.generatedBody)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.logoPurple.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.logoPurple.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var prayerContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 12))
                Text("PRAYER")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundStyle(Theme.dawnAmber)

            Text(viewModel.generatedPrayer)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(7)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.dawnAmber.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.dawnAmber.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private var shareButton: some View {
        Button {
            shareText = "\u{201C}\(viewModel.selectedVerseText)\u{201D}\n\u{2014} \(viewModel.selectedVerseReference) (\(viewModel.translationAbbreviation))\n\n\(viewModel.generatedTitle)\n\(viewModel.generatedBody)\n\nPrayer:\n\(viewModel.generatedPrayer)\n\nShared from God First \u{2728}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
            showShareSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15))
                Text("Share This Devotional")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [Theme.logoBlue, Theme.logoPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
        }
        .padding(.top, 8)
    }
}
