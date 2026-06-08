import SwiftUI

// The interactive star field. Tap stars to connect them; drag empty space to
// pan/explore. No physics — pure coordinate math + timer-based twinkle.
struct WeaverWeaveView: View {
    let sky: WeaverSky
    @EnvironmentObject var store: WeaverStore
    @Environment(\.presentationMode) private var presentationMode

    // Camera (in world points where world = canvasSize * worldScale).
    @State private var panOffset: CGSize = .zero
    @State private var liveDrag: CGSize = .zero
    @State private var isPanning = false

    // Working figure.
    @State private var selectedIds: [Int] = []     // path of taps (for chaining)
    @State private var edges: [WeaverEdge] = []
    @State private var lastTappedId: Int? = nil

    @State private var showSaveSheet = false
    @State private var twinklePhase: CGFloat = 0
    private let timer = Timer.publish(every: 1.0 / 24.0, on: .main, in: .common).autoconnect()

    // World is larger than the screen so there's room to pan.
    private let worldScale: CGFloat = 1.8

    var body: some View {
        GeometryReader { geo in
            let screenSize = geo.size                       // parent-passed size (pitfall-safe)
            let worldSize = CGSize(width: screenSize.width * worldScale,
                                   height: screenSize.height * worldScale)
            let effectiveOffset = CGSize(width: panOffset.width + liveDrag.width,
                                         height: panOffset.height + liveDrag.height)

            ZStack {
                WeaverTheme.backgroundGradient.ignoresSafeArea()

                starCanvas(screenSize: screenSize, worldSize: worldSize, offset: effectiveOffset)
                    .contentShape(Rectangle())
                    .gesture(panGesture(screenSize: screenSize, worldSize: worldSize))
                    .simultaneousGesture(tapGesture(screenSize: screenSize, worldSize: worldSize, offset: effectiveOffset))

                VStack {
                    Spacer()
                    controlBar
                }
            }
            .onReceive(timer) { _ in
                twinklePhase += 1.0 / 24.0 / 6.0
                if twinklePhase > 1 { twinklePhase -= 1 }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    HStack(spacing: 4) {
                        WeaverBackIcon(size: 20, color: WeaverTheme.line)
                        Text("Skies").foregroundColor(WeaverTheme.line).font(.system(size: 15))
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text(sky.name)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            WeaverSaveSheet(sky: sky, stars: sky.stars, edges: edges) {
                // After save: clear the working figure.
                clearFigure()
            }
            .environmentObject(store)
        }
    }

    // MARK: - Canvas

    private func worldPoint(for star: WeaverStar, worldSize: CGSize) -> CGPoint {
        CGPoint(x: star.x * worldSize.width, y: star.y * worldSize.height)
    }

    // Screen position = worldPoint + offset, centered so origin sits mid-pan.
    private func screenPoint(for star: WeaverStar, screenSize: CGSize, worldSize: CGSize, offset: CGSize) -> CGPoint {
        let wp = worldPoint(for: star, worldSize: worldSize)
        let centerCorrection = CGSize(width: (screenSize.width - worldSize.width) / 2,
                                      height: (screenSize.height - worldSize.height) / 2)
        return CGPoint(x: wp.x + offset.width + centerCorrection.width,
                       y: wp.y + offset.height + centerCorrection.height)
    }

    private func starCanvas(screenSize: CGSize, worldSize: CGSize, offset: CGSize) -> some View {
        Canvas { ctx, _ in
            let accent = WeaverTheme.accent(sky.hueIndex)
            let lookup = Dictionary(sky.stars.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

            func sp(_ s: WeaverStar) -> CGPoint {
                screenPoint(for: s, screenSize: screenSize, worldSize: worldSize, offset: offset)
            }

            // Draw committed edges.
            var edgePath = Path()
            for e in edges {
                guard let a = lookup[e.a], let b = lookup[e.b] else { continue }
                edgePath.move(to: sp(a)); edgePath.addLine(to: sp(b))
            }
            ctx.stroke(edgePath, with: .color(accent.opacity(0.85)),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            // Pending segment from last tapped to nothing is not drawn; chain shows via edges.

            let connected = Set(edges.flatMap { [$0.a, $0.b] }).union(selectedIds)

            // Stars.
            for s in sky.stars {
                let p = sp(s)
                // Cull off-screen for perf.
                if p.x < -20 || p.y < -20 || p.x > screenSize.width + 20 || p.y > screenSize.height + 20 { continue }
                let tw = 0.5 + 0.5 * sin((twinklePhase + s.twinklePhase) * 2 * .pi)
                if connected.contains(s.id) {
                    let glow = 7.0
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - glow, y: p.y - glow, width: glow * 2, height: glow * 2)),
                             with: .color(accent.opacity(0.20)))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 3.2, y: p.y - 3.2, width: 6.4, height: 6.4)),
                             with: .color(WeaverTheme.starCore))
                    if s.id == lastTappedId {
                        ctx.stroke(Path(ellipseIn: CGRect(x: p.x - 8, y: p.y - 8, width: 16, height: 16)),
                                   with: .color(accent), lineWidth: 1.4)
                    }
                } else {
                    let base = 0.22 + s.magnitude * 0.55
                    let r = 1.0 + s.magnitude * 2.2
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                             with: .color(WeaverTheme.starCore.opacity(base * (0.55 + 0.45 * tw))))
                }
            }
        }
    }

    // MARK: - Gestures

    private func panGesture(screenSize: CGSize, worldSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                isPanning = true
                liveDrag = value.translation
            }
            .onEnded { value in
                var newOffset = CGSize(width: panOffset.width + value.translation.width,
                                       height: panOffset.height + value.translation.height)
                newOffset = clampOffset(newOffset, screenSize: screenSize, worldSize: worldSize)
                panOffset = newOffset
                liveDrag = .zero
                // Small delay reset so a pan doesn't register as a tap.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { isPanning = false }
            }
    }

    private func clampOffset(_ offset: CGSize, screenSize: CGSize, worldSize: CGSize) -> CGSize {
        // Allow the world to move so any part can reach screen, plus margin.
        let maxX = (worldSize.width - screenSize.width) / 2 + 60
        let maxY = (worldSize.height - screenSize.height) / 2 + 60
        return CGSize(width: min(max(offset.width, -maxX), maxX),
                      height: min(max(offset.height, -maxY), maxY))
    }

    private func tapGesture(screenSize: CGSize, worldSize: CGSize, offset: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { value in
                if isPanning { return }
                if abs(value.translation.width) > 8 || abs(value.translation.height) > 8 { return }
                handleTap(at: value.location, screenSize: screenSize, worldSize: worldSize, offset: offset)
            }
    }

    private func handleTap(at location: CGPoint, screenSize: CGSize, worldSize: CGSize, offset: CGSize) {
        // Find nearest star within hit radius.
        var best: (id: Int, dist: CGFloat)? = nil
        for s in sky.stars {
            let p = screenPoint(for: s, screenSize: screenSize, worldSize: worldSize, offset: offset)
            let dx = p.x - location.x, dy = p.y - location.y
            let d = dx * dx + dy * dy
            if best == nil || d < best!.dist { best = (s.id, d) }
        }
        guard let hit = best, hit.dist <= 30 * 30 else { return }

        if let last = lastTappedId {
            if last == hit.id {
                // tapping the same star ends the current chain (lift the pen)
                lastTappedId = nil
                return
            }
            // connect last -> hit, avoid duplicate edge
            let exists = edges.contains { ($0.a == last && $0.b == hit.id) || ($0.a == hit.id && $0.b == last) }
            if !exists {
                edges.append(WeaverEdge(a: last, b: hit.id))
            }
            if !selectedIds.contains(hit.id) { selectedIds.append(hit.id) }
            lastTappedId = hit.id
        } else {
            // start a new chain
            if !selectedIds.contains(hit.id) { selectedIds.append(hit.id) }
            lastTappedId = hit.id
        }
    }

    // MARK: - Controls

    private var controlBar: some View {
        VStack(spacing: 10) {
            if !edges.isEmpty || !selectedIds.isEmpty {
                Text(hintText)
                    .font(.system(size: 12))
                    .foregroundColor(WeaverTheme.textSecondary)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(WeaverTheme.panel.opacity(0.85))
                    .clipShape(Capsule())
            } else {
                Text("Tap stars to connect them. Drag to explore the sky.")
                    .font(.system(size: 12))
                    .foregroundColor(WeaverTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(WeaverTheme.panel.opacity(0.85))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                actionButton(title: "Undo", enabled: !edges.isEmpty) { undo() }
                actionButton(title: "Clear", enabled: !edges.isEmpty || !selectedIds.isEmpty) { clearFigure() }
                Button { showSaveSheet = true } label: {
                    Text("Save Figure")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(edges.isEmpty ? WeaverTheme.textFaint : WeaverTheme.skyTop)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(edges.isEmpty ? WeaverTheme.panel : WeaverTheme.line)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(edges.isEmpty)
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            WeaverTheme.panel.opacity(0.92)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private var hintText: String {
        let n = edges.count
        if lastTappedId != nil {
            return "\(n) line\(n == 1 ? "" : "s") — tap another star to extend"
        }
        return "\(n) line\(n == 1 ? "" : "s") — tap a star to start a new strand"
    }

    private func actionButton(title: String, enabled: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(enabled ? WeaverTheme.textPrimary : WeaverTheme.textFaint)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(WeaverTheme.panelRaised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    private func undo() {
        guard !edges.isEmpty else { return }
        let removed = edges.removeLast()
        // Recompute selected ids & last tapped.
        let remaining = Set(edges.flatMap { [$0.a, $0.b] })
        selectedIds = selectedIds.filter { remaining.contains($0) }
        lastTappedId = remaining.contains(removed.b) ? removed.b : (remaining.contains(removed.a) ? removed.a : selectedIds.last)
        if edges.isEmpty { selectedIds = []; lastTappedId = nil }
    }

    private func clearFigure() {
        edges = []
        selectedIds = []
        lastTappedId = nil
    }
}
