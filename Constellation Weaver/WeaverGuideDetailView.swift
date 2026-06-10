import SwiftUI

// Renders a catalog target's canonical figure via WeaverFigureView by mapping
// the target's normalized points → WeaverStar (id == point index) and its edges
// → WeaverEdge. When `revealed` is false the figure is hidden behind a faint
// silhouette so locked constellations stay a tasteful mystery.
struct WeaverTargetFigure: View {
    let target: WeaverTarget
    var revealed: Bool = true

    private var stars: [WeaverStar] {
        target.points.enumerated().map { i, p in
            let phase = CGFloat((i &* 2654435761) % 1000) / 1000.0
            return WeaverStar(id: i, x: p.x, y: p.y, magnitude: 0.9, twinklePhase: phase)
        }
    }

    private var edges: [WeaverEdge] {
        target.edges.map { WeaverEdge(a: $0.0, b: $0.1) }
    }

    var body: some View {
        ZStack {
            WeaverFigureView(stars: stars, edges: edges,
                             hueIndex: target.hueIndex,
                             showAllStars: false, twinkle: revealed)
                .opacity(revealed ? 1 : 0.18)
            if !revealed {
                VStack(spacing: 8) {
                    WeaverLockIcon(size: 30, color: WeaverTheme.textFaint)
                        .frame(width: 32, height: 32)
                    Text("Trace it to reveal the figure")
                        .font(.system(size: 12))
                        .foregroundColor(WeaverTheme.textFaint)
                }
            }
        }
    }
}

// A scrollable Sky-Guide detail page for one constellation: the figure, its
// mythology, brightest stars, season + hemisphere, how-to-find tip, the sets it
// belongs to, discovered status, and a prominent button that opens the weave
// view in trace mode for it.
struct WeaverGuideDetailView: View {
    let target: WeaverTarget
    @EnvironmentObject var store: WeaverStore

    private var discovered: Bool { store.isDiscovered(target.id) }
    private var accent: Color { WeaverTheme.accent(target.hueIndex) }

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    figurePanel
                    titleBlock
                    if !target.mythology.isEmpty { mythologyBlock }
                    factsGrid
                    if !target.brightestStars.isEmpty { brightestBlock }
                    if !target.howToFind.isEmpty { howToFindBlock }
                    if !memberSets.isEmpty { setsBlock }
                    traceButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sky Guide")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
    }

    // MARK: - Sections

    private var figurePanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(WeaverTheme.skyTop)
            WeaverTargetFigure(target: target, revealed: discovered)
                .padding(18)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .frame(height: 230)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(target.name)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundColor(WeaverTheme.textPrimary)
            HStack(spacing: 8) {
                if discovered {
                    HStack(spacing: 6) {
                        WeaverCheckIcon(size: 13, color: accent).frame(width: 13, height: 13)
                        Text("Discovered")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(WeaverTheme.panelRaised))
                } else {
                    Text("Not yet discovered")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(WeaverTheme.textFaint)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(WeaverTheme.panel))
                }
            }
        }
    }

    private var mythologyBlock: some View {
        Text(target.mythology)
            .font(.system(size: 15))
            .foregroundColor(WeaverTheme.textSecondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var factsGrid: some View {
        HStack(spacing: 12) {
            factCard(label: "Best season", value: target.season.isEmpty ? "—" : target.season)
            factCard(label: "Hemisphere", value: target.hemisphere.isEmpty ? "—" : target.hemisphere)
        }
    }

    private func factCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(WeaverTheme.textFaint)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(WeaverTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.5), lineWidth: 1))
    }

    private var brightestBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Brightest stars")
            FlowingTags(tags: target.brightestStars, accent: accent)
        }
    }

    private var howToFindBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("How to find it")
            HStack(alignment: .top, spacing: 12) {
                WeaverTraceIcon(size: 22, color: accent)
                    .frame(width: 24, height: 24)
                    .padding(.top, 1)
                Text(target.howToFind)
                    .font(.system(size: 14))
                    .foregroundColor(WeaverTheme.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WeaverTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.5), lineWidth: 1))
        }
    }

    private var memberSets: [WeaverSet] { WeaverSets.sets(containing: target.id) }

    private var setsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Part of these collections")
            FlowingTags(tags: memberSets.map { $0.name }, accent: WeaverTheme.line)
        }
    }

    private var traceButton: some View {
        NavigationLink {
            WeaverWeaveView(sky: WeaverTraceSky.make(for: target),
                            mode: .trace(target))
        } label: {
            HStack(spacing: 10) {
                WeaverTraceIcon(size: 20, color: WeaverTheme.skyTop)
                    .frame(width: 22, height: 22)
                Text(discovered ? "Trace it again" : "Trace this constellation")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(WeaverTheme.skyTop)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(WeaverTheme.line)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .foregroundColor(WeaverTheme.textPrimary)
    }
}

// Simple wrapping tag row built from HStacks (no Grid / FlowLayout — iOS 15).
private struct FlowingTags: View {
    let tags: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: 8) {
                    ForEach(rows[r], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(WeaverTheme.textPrimary)
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(WeaverTheme.panelRaised)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(accent.opacity(0.5), lineWidth: 1))
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // Greedily pack tags into rows of up to 2 (keeps long star names readable).
    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []
        for tag in tags {
            current.append(tag)
            if current.count == 2 { result.append(current); current = [] }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}
