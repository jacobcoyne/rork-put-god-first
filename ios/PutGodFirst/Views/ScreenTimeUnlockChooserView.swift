import SwiftUI

struct ScreenTimeUnlockChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showScriptureUnlock: Bool = false
    @State private var showBibleScanner: Bool = false
    @State private var appear: Bool = false

    var onUnlocked: (() -> Void)?

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                VStack(spacing: 0) {
                    Spacer().frame(height: 32)

                    iconSection
                        .scaleEffect(appear ? 1 : 0.5)
                        .opacity(appear ? 1 : 0)

                    Spacer().frame(height: 24)

                    VStack(spacing: 8) {
                        Text("Apps Are Locked")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)

                        Text("Choose how to unlock your apps")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 12)

                    Spacer().frame(height: 32)

                    VStack(spacing: 12) {
                        unlockOptionCard(
                            icon: "mic.fill",
                            iconColor: Theme.icePurple,
                            iconBg: LinearGradient(
                                colors: [Theme.icePurple.opacity(0.15), Theme.logoIndigo.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            title: "Recite Scripture",
                            subtitle: "Read a Bible verse aloud to unlock",
                            action: { showScriptureUnlock = true }
                        )

                        unlockOptionCard(
                            icon: "camera.fill",
                            iconColor: Theme.logoBlue,
                            iconBg: LinearGradient(
                                colors: [Theme.logoBlue.opacity(0.15), Theme.logoIndigo.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            title: "Show Your Open Bible",
                            subtitle: "Take a photo of your open Bible to unlock",
                            action: { showBibleScanner = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)

                    Spacer()

                    VStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("Put God first — then enjoy your apps freely")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Theme.textSecondary.opacity(0.7))

                        Button {
                            dismiss()
                        } label: {
                            Text("Dismiss")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                    appear = true
                }
            }
            .fullScreenCover(isPresented: $showScriptureUnlock) {
                ScriptureUnlockView {
                    performFullUnlock()
                    onUnlocked?()
                    dismiss()
                }
            }
            .fullScreenCover(isPresented: $showBibleScanner) {
                ScreenTimeBibleScannerView {
                    performFullUnlock()
                    onUnlocked?()
                    dismiss()
                }
            }
        }
    }

    private func performFullUnlock() {
        let st = ScreenTimeService.shared
        st.clearManualFocusLock()
        if st.isBlocking {
            st.unblockApps()
        }
        let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.synchronize()
        st.refreshBlockingState()
    }

    private func unlockOptionCard(
        icon: String,
        iconColor: Color,
        iconBg: LinearGradient,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBg)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isDark ? Theme.cardBg : Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    Theme.icePurple.opacity(isDark ? 0.15 : 0.12)
                )
                .frame(width: 100, height: 100)

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(Theme.icePurple)
        }
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        if isDark {
            Color(.systemBackground)
                .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.96),
                    Color(red: 0.97, green: 0.96, blue: 0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}
