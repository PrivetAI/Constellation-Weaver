import SwiftUI

// Trace tab: BOTH the challenge list AND the collection. A grid of every target
// constellation — locked (silhouette / "?") vs discovered (the traced figure +
// name) — with an "X / N discovered" progress header. Tapping a target opens the
// weave view in trace mode for that constellation.
struct WeaverTraceView: View {
    @EnvironmentObject var store: WeaverStore

    private let columns = [GridItem(.adaptive(minimum: 165), spacing: 14)]

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(WeaverConstellationCatalog.targets) { target in
                            NavigationLink {
                                WeaverWeaveView(sky: WeaverTraceSky.make(for: target),
                                                mode: .trace(target))
                            } label: {
                                WeaverTraceCard(target: target,
                                                discovered: store.isDiscovered(target.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Trace the Stars")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
    }

    private var header: some View {
        let discovered = store.discoveredCount
        let total = WeaverConstellationCatalog.count
        return VStack(alignment: .leading, spacing: 10) {
            Text("Real constellations to find")
                .font(.system(size: 15))
                .foregroundColor(WeaverTheme.textSecondary)
            Text("Pick one, follow the faint guide, and connect its marked stars to discover it.")
                .font(.system(size: 13))
                .foregroundColor(WeaverTheme.textFaint)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text("\(discovered) / \(total) discovered")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(WeaverTheme.line)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(WeaverTheme.panelRaised)
                        Capsule()
                            .fill(WeaverTheme.line)
                            .frame(width: total == 0 ? 0 : g.size.width * CGFloat(discovered) / CGFloat(total))
                    }
                }
                .frame(height: 6)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// A grid card: discovered shows the traced figure + name; locked shows a faint
// silhouette of the figure with a "?" badge.
private struct WeaverTraceCard: View {
    let target: WeaverTarget
    let discovered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(WeaverTheme.skyTop)
                WeaverTargetPreview(target: target, discovered: discovered)
                    .padding(14)
                if !discovered {
                    VStack {
                        HStack {
                            Spacer()
                            Text("?")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(WeaverTheme.textFaint)
                                .frame(width: 26, height: 26)
                                .background(Circle().fill(WeaverTheme.panel.opacity(0.9)))
                                .overlay(Circle().stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 130)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(discovered ? target.name : "Undiscovered")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundColor(discovered ? WeaverTheme.textPrimary : WeaverTheme.textFaint)
                        .lineLimit(1)
                    Spacer()
                    if discovered {
                        WeaverCheckIcon(size: 14, color: WeaverTheme.accent(target.hueIndex))
                            .frame(width: 14, height: 14)
                    }
                }
                Text(discovered ? target.fact : "Tap to trace this pattern")
                    .font(.system(size: 11))
                    .foregroundColor(WeaverTheme.textFaint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}

// Static preview of a target's figure. Discovered = full accent lines + bright
// stars; locked = a faint silhouette of the same pattern.
private struct WeaverTargetPreview: View {
    let target: WeaverTarget
    let discovered: Bool

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            Canvas { ctx, _ in
                let accent = WeaverTheme.accent(target.hueIndex)
                func pt(_ i: Int) -> CGPoint {
                    let p = target.points[i]
                    return CGPoint(x: p.x * size.width, y: p.y * size.height)
                }
                var path = Path()
                for (a, b) in target.edges where a < target.points.count && b < target.points.count {
                    path.move(to: pt(a)); path.addLine(to: pt(b))
                }
                ctx.stroke(path,
                           with: .color(discovered ? accent.opacity(0.85) : WeaverTheme.textFaint.opacity(0.30)),
                           style: StrokeStyle(lineWidth: discovered ? 1.6 : 1.2, lineCap: .round, lineJoin: .round))
                for i in 0..<target.points.count {
                    let p = pt(i)
                    if discovered {
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)),
                                 with: .color(accent.opacity(0.18)))
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.4, y: p.y - 2.4, width: 4.8, height: 4.8)),
                                 with: .color(WeaverTheme.starCore))
                    } else {
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.0, y: p.y - 2.0, width: 4.0, height: 4.0)),
                                 with: .color(WeaverTheme.textFaint.opacity(0.45)))
                    }
                }
            }
        }
    }
}

// Builds a deterministic trace sky for a target: the target's stars occupy ids
// 0..<points.count at their exact normalized positions; filler background stars
// follow with higher ids. The weave view relies on id == target-point index.
enum WeaverTraceSky {
    static func make(for target: WeaverTarget) -> WeaverSky {
        var stars: [WeaverStar] = []
        stars.reserveCapacity(target.points.count + 60)

        // Target stars first, id == point index. Bright + lively.
        for (i, p) in target.points.enumerated() {
            // A stable per-point twinkle phase derived from the index.
            let phase = CGFloat((i &* 2654435761) % 1000) / 1000.0
            stars.append(WeaverStar(id: i,
                                    x: p.x,
                                    y: p.y,
                                    magnitude: 0.85,
                                    twinklePhase: phase))
        }

        // Deterministic filler background stars, avoiding the target stars.
        let seedBase = target.id.unicodeScalars.reduce(UInt64(0x51EED)) { acc, u in
            acc &* 1099511628211 &+ UInt64(u.value)
        }
        var rng = WeaverRandom(seed: seedBase)
        let fillerCount = 56
        var nextId = target.points.count
        var placed = 0
        var guard0 = 0
        while placed < fillerCount && guard0 < fillerCount * 8 {
            guard0 += 1
            let x = rng.range(0.04, 0.96)
            let y = rng.range(0.04, 0.96)
            // Keep filler from crowding target stars.
            var tooClose = false
            for p in target.points {
                let dx = p.x - x, dy = p.y - y
                if dx * dx + dy * dy < 0.0045 { tooClose = true; break }
            }
            if tooClose { continue }
            let raw = rng.unit()
            let mag = raw * raw * 0.6   // filler stays dim so target stars stand out
            let phase = rng.unit()
            stars.append(WeaverStar(id: nextId, x: x, y: y, magnitude: mag, twinklePhase: phase))
            nextId += 1
            placed += 1
        }

        return WeaverSky(id: -1,
                         name: target.name,
                         seed: seedBase,
                         hueIndex: target.hueIndex,
                         stars: stars)
    }
}
