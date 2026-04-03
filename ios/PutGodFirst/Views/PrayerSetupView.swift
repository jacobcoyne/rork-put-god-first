import SwiftUI

struct PrayerSetupView: View {
    @Bindable var viewModel: AppViewModel
    var onDismiss: (() -> Void)? = nil
    let onComplete: () -> Void

    @State private var sliderDuration: Double
    @State private var selectedMode: PrayerMode
    @State private var showTimer: Bool = false
    @State private var showPrayerPicker: Bool = false
    @State private var selectedPrayer: Prayer?

    init(viewModel: AppViewModel, onDismiss: (() -> Void)? = nil, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        self.onComplete = onComplete
        self._sliderDuration = State(initialValue: Double(viewModel.prayerDurationMinutes))
        self._selectedMode = State(initialValue: viewModel.selectedPrayerMode)
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if showTimer {
                PrayerTimerView(
                    durationMinutes: Int(sliderDuration),
                    journeyStyle: viewModel.journeyStyle,
                    selectedPrayer: selectedPrayer,
                    prayerMode: selectedMode,
                    onComplete: onComplete
                )
                .id("timer")
                .transition(.move(edge: .trailing))
            } else {
                setupContent
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showTimer)
    }

    private var setupContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    (onDismiss ?? onComplete)()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Theme.cardBg))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Text("Set Up Your\nPrayer Time")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    VStack(spacing: 16) {
                        Label("Duration", systemImage: "clock")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase)

                        Text("\(Int(sliderDuration)) min")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.prayerTeal)

                        Slider(value: $sliderDuration, in: 1...30, step: 1)
                            .tint(Theme.prayerTeal)
                            .padding(.horizontal, 8)

                        HStack {
                            Text("1 min")
                            Spacer()
                            Text("30 min")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.cardBg)
                    )

                    VStack(spacing: 14) {
                        Text("PRAYER STYLE")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)

                        ForEach(PrayerMode.allCases) { mode in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedMode = mode
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: mode.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Theme.prayerTeal)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mode.rawValue)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        Text(mode.subtitle)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Spacer()
                                    if selectedMode == mode {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Theme.prayerTeal)
                                    }
                                }
                                .foregroundStyle(Theme.textPrimary)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedMode == mode ? Theme.prayerTeal.opacity(0.1) : Theme.cardBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(selectedMode == mode ? Theme.prayerTeal : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }

            VStack(spacing: 0) {
                Button {
                    if selectedMode == .pickPrayer {
                        showPrayerPicker = true
                    } else {
                        viewModel.prayerDurationMinutes = Int(sliderDuration)
                        viewModel.selectedPrayerMode = selectedMode
                        withAnimation { showTimer = true }
                    }
                } label: {
                    Text(selectedMode == .pickPrayer ? "Choose a Prayer" : "Begin Prayer")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Capsule().fill(Theme.prayerGradient))
                        .shadow(color: Theme.prayerTeal.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(
                Theme.bg
                    .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
            )
        }
        .sheet(isPresented: $showPrayerPicker) {
            PrayerPickerSheet(selectedPrayer: $selectedPrayer) {
                showPrayerPicker = false
                viewModel.prayerDurationMinutes = Int(sliderDuration)
                viewModel.selectedPrayerMode = selectedMode
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { showTimer = true }
                }
            }
        }
    }
}

struct PrayerPickerSheet: View {
    @Binding var selectedPrayer: Prayer?
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(PrayerCategory.allCases) { category in
                        let prayers = PrayerLibrary.prayers(for: category)
                        if !prayers.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.prayerTeal)
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Theme.textPrimary)
                                }
                                .padding(.top, 8)

                                ForEach(prayers) { prayer in
                                    Button {
                                        selectedPrayer = prayer
                                        onSelect()
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
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(Theme.textSecondary.opacity(0.5))
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Theme.cardBg)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Pick a Prayer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}
