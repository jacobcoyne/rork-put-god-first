import SwiftUI
import FamilyControls

struct GodFirstModeSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activitySelection: FamilyActivitySelection = ScreenTimeService.shared.activitySelection
    @State private var showingPicker: Bool = false
    var onActivate: () -> Void

    private var selectedCount: Int {
        activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.logoIndigo.opacity(0.2), Theme.logoIndigo.opacity(0.05), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "shield.checkered")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.logoBlue, Theme.logoIndigo],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12)
                }

                VStack(spacing: 10) {
                    Text("Choose Apps to Block")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Select apps to block when God First Mode is active.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    showingPicker = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.logoBlue.opacity(0.15), Theme.logoIndigo.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)

                            Image(systemName: "apps.iphone")
                                .font(.system(size: 24))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.logoBlue, Theme.logoIndigo],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Select Apps & Categories")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)

                            if selectedCount > 0 {
                                Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") selected")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.logoBlue)
                            } else {
                                Text("Tap to choose from your installed apps")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(
                                        selectedCount > 0 ? Theme.logoBlue.opacity(0.3) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    )
                }
                .familyActivityPicker(
                    isPresented: $showingPicker,
                    selection: $activitySelection
                )
                .onChange(of: activitySelection) { _, newValue in
                    ScreenTimeService.shared.activitySelection = newValue
                }

                if selectedCount > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.limeGreen)
                        Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") will be blocked")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.limeGreen)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onActivate()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 15, weight: .bold))
                        Text("Activate God First Mode")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12, y: 6)
                }
                .disabled(selectedCount == 0)
                .opacity(selectedCount == 0 ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .background(Theme.bg)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
