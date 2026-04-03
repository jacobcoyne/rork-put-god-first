import SwiftUI

struct PrayerLibraryView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedPrayer: Prayer?
    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    let favPrayers = PrayerLibrary.prayers.filter { viewModel.isFavorite($0) }
                    if !favPrayers.isEmpty {
                        favoritesSection(favPrayers)
                    }

                    ForEach(PrayerCategory.allCases) { category in
                        let prayers = PrayerLibrary.prayers(for: category)
                        if !prayers.isEmpty {
                            categorySection(category, prayers: prayers)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Prayers")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPrayer) { prayer in
                PrayerDetailView(prayer: prayer, isFavorite: viewModel.isFavorite(prayer)) {
                    viewModel.toggleFavorite(prayer)
                }
            }
            .onAppear {
                if !appeared {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appeared = true
                    }
                }
            }
        }
    }

    private func categorySection(_ category: PrayerCategory, prayers: [Prayer]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.prayerTeal)
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.top, 10)

            ForEach(prayers) { prayer in
                prayerRow(prayer)
            }
        }
    }

    private func favoritesSection(_ prayers: [Prayer]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.coral)
                Text("Favorites")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.top, 10)

            ForEach(prayers) { prayer in
                prayerRow(prayer)
            }
        }
    }

    private func prayerRow(_ prayer: Prayer) -> some View {
        Button {
            selectedPrayer = prayer
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(prayer.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(prayer.author)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                if viewModel.isFavorite(prayer) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.coral)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.prayerTeal.opacity(0.4))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.cardBg)
            )
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var textLines: [Bool] = Array(repeating: false, count: 20)
    @State private var hapticTrigger: Int = 0

    private var paragraphs: [String] {
        prayer.text.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 10)

                    HStack(spacing: 6) {
                        Image(systemName: "book")
                            .font(.system(size: 13))
                        Text("PRAYER")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundStyle(.white.opacity(0.35))
                    .opacity(textLines[0] ? 1 : 0)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(prayer.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(textLines[1] ? 1 : 0)
                            .offset(y: textLines[1] ? 0 : 12)

                        Text("by \(prayer.author)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                            .opacity(textLines[2] ? 1 : 0)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.primary.opacity(0.7), Theme.skyBlue.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 40, height: 3)
                            .clipShape(Capsule())
                            .opacity(textLines[2] ? 1 : 0)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                            Text(paragraph)
                                .font(.system(size: 21, weight: .regular, design: .serif))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(10)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(textLines[min(index + 3, textLines.count - 1)] ? 1 : 0)
                                .offset(y: textLines[min(index + 3, textLines.count - 1)] ? 0 : 16)
                        }
                    }

                    if !paragraphs.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "hands.sparkles")
                                .font(.system(size: 13))
                                .symbolEffect(.breathe)
                            Text("Amen")
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                        }
                        .foregroundStyle(Theme.skyBlue.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .opacity(textLines[min(paragraphs.count + 3, textLines.count - 1)] ? 1 : 0)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.03, blue: 0.09),
                        Color(red: 0.06, green: 0.04, blue: 0.14),
                        Color(red: 0.04, green: 0.03, blue: 0.09)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { toggleFavorite() } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? Theme.coral : .white.opacity(0.5))
                            .symbolEffect(.bounce, value: isFavorite)
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.skyBlue)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .sensoryFeedback(.impact(weight: .light, intensity: 0.5), trigger: hapticTrigger)
        }
        .onAppear {
            let totalElements = min(paragraphs.count + 4, textLines.count)
            for i in 0..<totalElements {
                let delay = 0.3 + Double(i) * 0.7
                withAnimation(.easeOut(duration: 1.0).delay(delay)) { textLines[i] = true }
            }
            hapticTrigger += 1
        }
        .preferredColorScheme(.dark)
    }
}
