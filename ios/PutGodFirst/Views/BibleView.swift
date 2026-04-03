import SwiftUI

struct BibleView: View {
    @State private var viewModel = BibleViewModel()
    @State private var appearAnimation: Bool = false
    @State private var showTranslationPicker: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    translationBanner
                    testamentPicker
                    continueReadingCard
                    booksList
                }
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Bible")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search books...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    translationButton
                }
            }
            .sheet(isPresented: $showTranslationPicker) {
                TranslationPickerSheet(viewModel: viewModel)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
        .task {
            await viewModel.loadTranslations()
        }
    }

    private var translationButton: some View {
        Button {
            showTranslationPicker = true
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.translationAbbreviation)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(Theme.logoBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Theme.logoBlue.opacity(0.1))
            )
        }
    }

    @ViewBuilder
    private var translationBanner: some View {
        if viewModel.isLoadingTranslations {
            HStack(spacing: 10) {
                ProgressView()
                    .tint(Theme.logoBlue)
                Text("Loading translations...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        } else if viewModel.availableTranslations.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.dawnAmber)
                Text("Could not load translations")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                Button("Retry") {
                    Task { await viewModel.loadTranslations() }
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.logoBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private var testamentPicker: some View {
        HStack(spacing: 0) {
            ForEach(Testament.allCases) { testament in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.selectedTestament = testament
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(testament == .old ? "Old Testament" : "New Testament")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(viewModel.selectedTestament == testament ? .white : Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if viewModel.selectedTestament == testament {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.logoBlue, Theme.logoPurple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(
            Capsule().fill(Color(.tertiarySystemFill))
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var continueReadingCard: some View {
        if !viewModel.lastReadBook.isEmpty,
           let book = BibleBook.allBooks.first(where: { $0.id == viewModel.lastReadBook }),
           viewModel.lastReadChapter > 0 {
            NavigationLink {
                BibleChapterListView(book: book, viewModel: viewModel)
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.logoBlue.opacity(0.2), Theme.logoPurple.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.logoBlue, Theme.logoPurple],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Continue Reading")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        Text("\(book.name) \(viewModel.lastReadChapter)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Theme.logoBlue.opacity(0.06), Theme.logoPurple.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Theme.logoBlue.opacity(0.15), Theme.logoPurple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var booksList: some View {
        LazyVStack(spacing: 6) {
            ForEach(Array(viewModel.filteredBooks.enumerated()), id: \.element.id) { index, book in
                NavigationLink {
                    BibleChapterListView(book: book, viewModel: viewModel)
                } label: {
                    bookCard(book: book, index: index)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func bookCard(book: BibleBook, index: Int) -> some View {
        let color = colorForBook(index: index)
        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)

                Text(book.abbreviation)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(book.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(book.chapters) chapter\(book.chapters == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.cardBg)
        )
    }

    private func colorForBook(index: Int) -> Color {
        let colors: [Color] = [
            Theme.logoBlue, Theme.logoPurple, Theme.logoIndigo,
            Theme.dawnAmber, Color(red: 0.18, green: 0.58, blue: 0.56),
            Theme.dustyRose, Theme.logoDeepPurple
        ]
        return colors[index % colors.count]
    }
}

struct BibleChapterListView: View {
    let book: BibleBook
    @Bindable var viewModel: BibleViewModel
    @State private var animateGrid: Bool = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                bookHeader
                chapterGrid
            }
            .padding(.bottom, 40)
        }
        .background(Theme.bg)
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateGrid = true
            }
        }
    }

    private var bookHeader: some View {
        VStack(spacing: 8) {
            Text(book.testament == .old ? "Old Testament" : "New Testament")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text("\(book.chapters) Chapter\(book.chapters == 1 ? "" : "s")")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, 4)
    }

    private var chapterGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...book.chapters, id: \.self) { chapter in
                NavigationLink {
                    BibleChapterReadingView(book: book, chapter: chapter, viewModel: viewModel)
                } label: {
                    chapterCell(chapter)
                        .opacity(animateGrid ? 1 : 0)
                        .offset(y: animateGrid ? 0 : 10)
                        .animation(
                            .spring(response: 0.35, dampingFraction: 0.8).delay(Double(min(chapter - 1, 30)) * 0.008),
                            value: animateGrid
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func chapterCell(_ chapter: Int) -> some View {
        let isLastRead = viewModel.lastReadBook == book.id && viewModel.lastReadChapter == chapter

        return Text("\(chapter)")
            .font(.system(size: 17, weight: isLastRead ? .bold : .medium, design: .rounded))
            .foregroundStyle(isLastRead ? .white : Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isLastRead
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Theme.logoBlue, Theme.logoPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Theme.cardBg)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isLastRead ? Color.clear : Color(.separator).opacity(0.3),
                        lineWidth: 0.5
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isLastRead {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(6)
                }
            }
    }
}

struct TranslationPickerSheet: View {
    @Bindable var viewModel: BibleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""

    private var filteredTranslations: [BibleTranslation] {
        if searchQuery.isEmpty { return viewModel.availableTranslations }
        return viewModel.availableTranslations.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTranslations) { translation in
                    Button {
                        viewModel.selectTranslation(translation)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(translation.abbreviation)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(translation.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if translation.id == viewModel.selectedTranslation?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Theme.logoBlue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $searchQuery, prompt: "Search translations...")
            .navigationTitle("Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.logoBlue)
                }
            }
        }
    }
}
