import SwiftUI

struct WeaverAchievementsView: View {
    @EnvironmentObject var store: WeaverStore
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Text("\(store.unlockedAchievements.count) of \(WeaverAchievementsCatalog.count) earned")
                        .font(.system(size: 14))
                        .foregroundColor(WeaverTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    VStack(spacing: 12) {
                        ForEach(WeaverAchievementsCatalog.all) { a in
                            row(a, earned: store.isAchievementUnlocked(a.id))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    HStack(spacing: 4) {
                        WeaverBackIcon(size: 20, color: WeaverTheme.line)
                        Text("Settings").foregroundColor(WeaverTheme.line).font(.system(size: 15))
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Achievements")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
    }

    private func row(_ a: WeaverAchievement, earned: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(earned ? WeaverTheme.panelRaised : WeaverTheme.panel)
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(WeaverTheme.stroke.opacity(earned ? 0.8 : 0.4), lineWidth: 1))
                if earned {
                    WeaverTrophyIcon(size: 24, color: WeaverTheme.line)
                } else {
                    WeaverLockIcon(size: 20, color: WeaverTheme.textFaint)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(a.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(earned ? WeaverTheme.textPrimary : WeaverTheme.textFaint)
                Text(a.detail)
                    .font(.system(size: 13))
                    .foregroundColor(WeaverTheme.textSecondary.opacity(earned ? 1.0 : 0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if earned {
                WeaverCheckIcon(size: 18, color: WeaverTheme.line)
                    .frame(width: 18, height: 18)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WeaverTheme.panel.opacity(earned ? 1.0 : 0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}
