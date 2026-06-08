import SwiftUI

// Renders a finished constellation (stars + edges) inside a given rect,
// using a parent-passed canvasSize (NOT the Canvas closure size — see skill).
// Static, no interaction. Used by detail & atlas thumbnails.
struct WeaverFigureView: View {
    let stars: [WeaverStar]
    let edges: [WeaverEdge]
    let hueIndex: Int
    var showAllStars: Bool = true
    var twinkle: Bool = true

    @State private var phase: CGFloat = 0
    private let timer = Timer.publish(every: 1.0 / 20.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let canvasSize = geo.size
            Canvas { ctx, _ in
                let usedIds = Set(edges.flatMap { [$0.a, $0.b] })
                let accent = WeaverTheme.accent(hueIndex)

                func point(_ s: WeaverStar) -> CGPoint {
                    CGPoint(x: s.x * canvasSize.width, y: s.y * canvasSize.height)
                }
                // Dedupe-tolerant: persisted/decoded data could (in a corrupt
                // file) repeat an id — uniquingKeysWith never traps on dupes.
                let lookup = Dictionary(stars.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

                // Background (unused) stars — faint.
                if showAllStars {
                    for s in stars where !usedIds.contains(s.id) {
                        let p = point(s)
                        let base = 0.10 + s.magnitude * 0.30
                        let tw = twinkle ? (0.5 + 0.5 * sin((phase + s.twinklePhase) * 2 * .pi)) : 1
                        let r = 0.6 + s.magnitude * 1.6
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                                 with: .color(WeaverTheme.starCore.opacity(base * (0.5 + 0.5 * tw))))
                    }
                }

                // Edges.
                var linePath = Path()
                for e in edges {
                    guard let a = lookup[e.a], let b = lookup[e.b] else { continue }
                    linePath.move(to: point(a))
                    linePath.addLine(to: point(b))
                }
                ctx.stroke(linePath,
                           with: .color(accent.opacity(0.85)),
                           style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))

                // Connected stars — bright glow.
                for id in usedIds {
                    guard let s = lookup[id] else { continue }
                    let p = point(s)
                    let tw = twinkle ? (0.7 + 0.3 * sin((phase + s.twinklePhase) * 2 * .pi)) : 1
                    let glow = 5.0 * tw
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - glow, y: p.y - glow, width: glow * 2, height: glow * 2)),
                             with: .color(accent.opacity(0.18)))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.6, y: p.y - 2.6, width: 5.2, height: 5.2)),
                             with: .color(WeaverTheme.starCore))
                }
            }
            .onReceive(timer) { _ in
                if twinkle {
                    phase += 1.0 / 20.0 / 6.0   // slow ~6s cycle
                    if phase > 1 { phase -= 1 }
                }
            }
        }
    }
}
