import SwiftUI

struct WeaverSkiesView: View {
    @EnvironmentObject var store: WeaverStore

    private let columns = [GridItem(.adaptive(minimum: 250), spacing: 16)]

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    WeaverDailyCard()
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(store.unlockedSkies) { sky in
                            NavigationLink {
                                WeaverWeaveView(sky: sky)
                            } label: {
                                WeaverSkyCard(sky: sky, count: store.count(forSky: sky.id))
                            }
                            .buttonStyle(.plain)
                        }

                        if store.canUnlockMore {
                            Button { store.unlockNextSky() } label: {
                                WeaverUnlockCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear { store.registerDailyVisit() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Night Skies")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a sky and weave your own figures")
                .font(.system(size: 15))
                .foregroundColor(WeaverTheme.textSecondary)
            Text("\(store.totalCount) figure\(store.totalCount == 1 ? "" : "s") woven so far  ·  try Trace to find real constellations")
                .font(.system(size: 13))
                .foregroundColor(WeaverTheme.textFaint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct WeaverSkyCard: View {
    let sky: WeaverSky
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(WeaverTheme.skyTop)
                WeaverSkyPreview(sky: sky)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .frame(height: 130)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(sky.name)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(WeaverTheme.textPrimary)
                    Spacer()
                    WeaverStarIcon(size: 13, color: WeaverTheme.accent(sky.hueIndex))
                }
                Text(count == 0 ? "Untouched — start weaving"
                                : "\(count) constellation\(count == 1 ? "" : "s") here")
                    .font(.system(size: 12))
                    .foregroundColor(WeaverTheme.textFaint)
            }
            .padding(12)
        }
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}

// Small static star-field preview of a sky.
private struct WeaverSkyPreview: View {
    let sky: WeaverSky

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            Canvas { ctx, _ in
                for s in sky.stars {
                    let p = CGPoint(x: s.x * size.width, y: s.y * size.height)
                    let r = 0.5 + s.magnitude * 1.8
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                             with: .color(WeaverTheme.starCore.opacity(0.25 + s.magnitude * 0.6)))
                }
            }
        }
    }
}

// Constellation of the Day: a deterministic daily pick (by date) shown at the
// top of the landing tab. Displays its figure, name and fact, the current return
// streak, and a button into its Sky-Guide detail page.
private struct WeaverDailyCard: View {
    @EnvironmentObject var store: WeaverStore

    private var target: WeaverTarget { store.dailyTarget() }
    private var accent: Color { WeaverTheme.accent(target.hueIndex) }

    var body: some View {
        NavigationLink {
            WeaverGuideDetailView(target: target)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(WeaverTheme.skyTop)
                    WeaverTargetFigure(target: target, revealed: true)
                        .padding(16)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    VStack {
                        HStack {
                            Text("CONSTELLATION OF THE DAY")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(WeaverTheme.textFaint)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Capsule().fill(WeaverTheme.panel.opacity(0.9)))
                            Spacer()
                            streakBadge
                        }
                        Spacer()
                    }
                    .padding(12)
                }
                .frame(height: 180)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(target.name)
                            .font(.system(size: 19, weight: .semibold, design: .serif))
                            .foregroundColor(WeaverTheme.textPrimary)
                        Spacer()
                        Text("Open guide")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                    }
                    Text(target.fact)
                        .font(.system(size: 13))
                        .foregroundColor(WeaverTheme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
            }
            .background(WeaverTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var streakBadge: some View {
        if store.dailyStreak > 0 {
            HStack(spacing: 5) {
                WeaverStreakIcon(size: 14, color: accent)
                    .frame(width: 14, height: 14)
                Text("\(store.dailyStreak)-day streak")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(WeaverTheme.panelRaised.opacity(0.95)))
        }
    }
}

private struct WeaverUnlockCard: View {
    var body: some View {
        VStack(spacing: 12) {
            WeaverPlusIcon(size: 34, color: WeaverTheme.line)
            Text("Reveal a new sky")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(WeaverTheme.textPrimary)
            Text("Generate a fresh field of stars")
                .font(.system(size: 12))
                .foregroundColor(WeaverTheme.textFaint)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 218)
        .background(WeaverTheme.panel.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(WeaverTheme.stroke, style: StrokeStyle(lineWidth: 1.4, dash: [6, 5]))
        )
    }
}
