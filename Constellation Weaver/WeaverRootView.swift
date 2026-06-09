import SwiftUI

struct WeaverRootView: View {
    @EnvironmentObject var store: WeaverStore
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { WeaverSkiesView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { WeaverTraceView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { WeaverAtlasView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { WeaverSettingsView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }

            // Transient achievement-unlock toast.
            if let a = store.recentAchievement {
                achievementToast(a)
                    .padding(.bottom, 96)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // First-launch (or replayed) onboarding overlay.
        .overlay(onboardingOverlay)
        .onChange(of: store.recentAchievement?.id) { _ in
            guard store.recentAchievement != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.3)) { store.recentAchievement = nil }
            }
        }
    }

    @ViewBuilder
    private var onboardingOverlay: some View {
        if !store.onboardingDone {
            WeaverOnboardingView { store.completeOnboarding() }
                .transition(.opacity)
        }
    }

    private func achievementToast(_ a: WeaverAchievement) -> some View {
        HStack(spacing: 12) {
            WeaverTrophyIcon(size: 24, color: WeaverTheme.line)
                .frame(width: 26, height: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement unlocked")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(WeaverTheme.textFaint)
                Text(a.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(WeaverTheme.panelRaised)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.7), lineWidth: 1))
        .padding(.horizontal, 28)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Skies",
                      icon: AnyView(WeaverSkiesIcon(size: 24, color: tint(0))))
            tabButton(index: 1, label: "Trace",
                      icon: AnyView(WeaverTraceIcon(size: 24, color: tint(1))))
            tabButton(index: 2, label: "Atlas",
                      icon: AnyView(WeaverAtlasIcon(size: 24, color: tint(2))))
            tabButton(index: 3, label: "Settings",
                      icon: AnyView(WeaverSettingsIcon(size: 24, color: tint(3))))
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            WeaverTheme.panel
                .overlay(Rectangle().frame(height: 1).foregroundColor(WeaverTheme.stroke.opacity(0.5)), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tint(_ index: Int) -> Color {
        selectedTab == index ? WeaverTheme.line : WeaverTheme.textFaint
    }

    private func tabButton(index: Int, label: String, icon: AnyView) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 5) {
                icon.frame(height: 26)
                Text(label)
                    .font(.system(size: 11, weight: selectedTab == index ? .semibold : .regular))
                    .foregroundColor(tint(index))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
