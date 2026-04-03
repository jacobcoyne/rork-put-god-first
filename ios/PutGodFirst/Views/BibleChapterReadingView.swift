import SwiftUI

struct BibleChapterReadingView: View {
    let book: BibleBook
    let chapter: Int
    @Bindable var viewModel: BibleViewModel
    @State private var fontSize: CGFloat = 18
    @State private var showFontSlider: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    chapterTitle
                    versesContent
                    chapterNavigation
                }
                .padding(.bottom, viewModel.selectedVerses.isEmpty ? 40 : 120)
            }
            .background(Theme.bg)

            if !viewModel.selectedVerses.isEmpty {
                selectionBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedVerses.isEmpty)
        .navigationTitle("\(book.name) \(chapter)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showFontSlider.toggle()
                    }
                } label: {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .task {
            await viewModel.loadChapter(book: book, chapter: chapter)
        }
        .sheet(isPresented: $viewModel.showDevotionalSheet) {
            VerseDevotionalSheet(viewModel: viewModel)
        }
        .safeAreaInset(edge: .top) {
            if showFontSlider {
                fontSizeControl
            }
        }
    }

    private var chapterTitle: some View {
        VStack(spacing: 6) {
            Text(book.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            Text("Chapter \(chapter)")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    @ViewBuilder
    private var versesContent: some View {
        if viewModel.isLoadingChapter {
            VStack(spacing: 16) {
                ProgressView()
                    .tint(Theme.logoBlue)
                    .scaleEffect(1.2)
                Text("Loading chapter...")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        } else if viewModel.verses.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.textSecondary)
                Text("Could not load chapter")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("Check your connection and try again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                Button("Retry") {
                    Task {
                        await viewModel.loadChapter(book: book, chapter: chapter)
                    }
                }
                .buttonStyle(.bordered)
                .tint(Theme.logoBlue)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.verses) { verse in
                    verseRow(verse)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func verseRow(_ verse: BibleVerse) -> some View {
        let isSelected = viewModel.selectedVerses.contains(verse.id)
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.toggleVerseSelection(verse)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(verse.verse)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Theme.logoBlue : Theme.textSecondary)
                    .frame(width: 24, alignment: .trailing)

                Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size: fontSize, weight: .regular, design: .serif))
                    .foregroundStyle(Theme.textPrimary)
                    .lineSpacing(fontSize * 0.5)
                    .tracking(0.2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.logoBlue.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Theme.logoBlue.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var chapterNavigation: some View {
        HStack {
            if chapter > 1 {
                NavigationLink {
                    BibleChapterReadingView(book: book, chapter: chapter - 1, viewModel: viewModel)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Chapter \(chapter - 1)")
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.logoBlue)
                }
            }

            Spacer()

            if chapter < book.chapters {
                NavigationLink {
                    BibleChapterReadingView(book: book, chapter: chapter + 1, viewModel: viewModel)
                } label: {
                    HStack(spacing: 6) {
                        Text("Chapter \(chapter + 1)")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.logoBlue)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 30)
    }

    private var selectionBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.selectedVerses.count) verse\(viewModel.selectedVerses.count == 1 ? "" : "s") selected")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text(viewModel.selectedVerseReference)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    viewModel.selectedVerses.removeAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(.tertiaryLabel))
                }

                Button {
                    Task {
                        await viewModel.generateDevotional()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text("Devotional")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
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
                .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.showDevotionalSheet)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
        }
    }

    private var fontSizeControl: some View {
        HStack(spacing: 14) {
            Image(systemName: "textformat.size.smaller")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)

            Slider(value: $fontSize, in: 14...28, step: 1)
                .tint(Theme.logoBlue)

            Image(systemName: "textformat.size.larger")
                .font(.system(size: 16))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
