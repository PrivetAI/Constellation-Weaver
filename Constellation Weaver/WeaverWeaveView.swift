import SwiftUI

// What the weave view is doing: free drawing, or tracing a known target.
enum WeaverWeaveMode: Equatable {
    case free
    case trace(WeaverTarget)

    var target: WeaverTarget? {
        if case let .trace(t) = self { return t }
        return nil
    }
}

// The interactive star field. Tap stars to connect them; drag empty space to
// pan/explore. No physics — pure coordinate math + timer-based twinkle.
struct WeaverWeaveView: View {
    let sky: WeaverSky
    var mode: WeaverWeaveMode = .free
    // Called when a trace target is fully discovered, so a parent (the Trace
    // grid) can offer "Next".
    var onDiscovered: ((WeaverTarget) -> Void)? = nil

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

    // Hint: when set, this star pulses for a short while.
    @State private var hintStarId: Int? = nil
    @State private var hintPulse: CGFloat = 0

    // Trace completion overlay.
    @State private var showDiscovered = false

    // World is larger than the screen so there's room to pan.
    private let worldScale: CGFloat = 1.8

    private var isTrace: Bool { mode.target != nil }

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

                if showDiscovered, let t = mode.target {
                    discoveredOverlay(t)
                }
            }
            .onReceive(timer) { _ in
                twinklePhase += 1.0 / 24.0 / 6.0
                if twinklePhase > 1 { twinklePhase -= 1 }
                if hintStarId != nil {
                    hintPulse += 1.0 / 24.0
                    if hintPulse > 2.4 { hintStarId = nil; hintPulse = 0 } // ~2.4s pulse
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
                        Text(isTrace ? "Trace" : "Skies").foregroundColor(WeaverTheme.line).font(.system(size: 15))
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text(mode.target?.name ?? sky.name)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            WeaverSaveSheet(sky: sky, stars: sky.stars, edges: edges) {
                clearFigure()
            }
            .environmentObject(store)
        }
    }

    // MARK: - Target geometry helpers

    // The ids of the sky's stars that correspond to the target's points, in
    // target-index order. By construction (see WeaverTraceView) these are the
    // first `points.count` stars of the trace sky, with id == point index.
    private var targetStarIds: [Int] {
        guard let t = mode.target else { return [] }
        return Array(0..<t.points.count)
    }

    private var targetStarIdSet: Set<Int> { Set(targetStarIds) }

    // Player's drawn edges expressed as canonical target keys (only edges whose
    // both endpoints are target stars count toward progress).
    private var drawnTargetKeys: Set<String> {
        guard mode.target != nil else { return [] }
        let ts = targetStarIdSet
        var keys: Set<String> = []
        for e in edges where ts.contains(e.a) && ts.contains(e.b) {
            keys.insert(WeaverTarget.key(e.a, e.b))
        }
        return keys
    }

    private var remainingTargetKeys: Set<String> {
        guard let t = mode.target else { return [] }
        return t.edgeKeys.subtracting(drawnTargetKeys)
    }

    // MARK: - Canvas

    private func worldPoint(for star: WeaverStar, worldSize: CGSize) -> CGPoint {
        CGPoint(x: star.x * worldSize.width, y: star.y * worldSize.height)
    }

    private func screenPoint(for star: WeaverStar, screenSize: CGSize, worldSize: CGSize, offset: CGSize) -> CGPoint {
        let wp = worldPoint(for: star, worldSize: worldSize)
        let centerCorrection = CGSize(width: (screenSize.width - worldSize.width) / 2,
                                      height: (screenSize.height - worldSize.height) / 2)
        return CGPoint(x: wp.x + offset.width + centerCorrection.width,
                       y: wp.y + offset.height + centerCorrection.height)
    }

    private func starCanvas(screenSize: CGSize, worldSize: CGSize, offset: CGSize) -> some View {
        Canvas { ctx, _ in
            let accent = WeaverTheme.accent(mode.target?.hueIndex ?? sky.hueIndex)
            let lookup = Dictionary(sky.stars.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

            func sp(_ s: WeaverStar) -> CGPoint {
                screenPoint(for: s, screenSize: screenSize, worldSize: worldSize, offset: offset)
            }

            // --- Trace: faint ghost of the full target pattern (the guide). ---
            if let t = mode.target {
                let ts = targetStarIds
                var ghost = Path()
                for (a, b) in t.edges {
                    guard a < ts.count, b < ts.count,
                          let sa = lookup[ts[a]], let sb = lookup[ts[b]] else { continue }
                    // Only draw the ghost for edges the player hasn't drawn yet.
                    if drawnTargetKeys.contains(WeaverTarget.key(ts[a], ts[b])) { continue }
                    ghost.move(to: sp(sa)); ghost.addLine(to: sp(sb))
                }
                ctx.stroke(ghost, with: .color(accent.opacity(0.22)),
                           style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round, dash: [5, 6]))
            }

            // --- Committed edges. ---
            var edgePath = Path()
            for e in edges {
                guard let a = lookup[e.a], let b = lookup[e.b] else { continue }
                edgePath.move(to: sp(a)); edgePath.addLine(to: sp(b))
            }
            ctx.stroke(edgePath, with: .color(accent.opacity(0.85)),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            let connected = Set(edges.flatMap { [$0.a, $0.b] }).union(selectedIds)
            let ts = targetStarIdSet

            // --- Stars. ---
            for s in sky.stars {
                let p = sp(s)
                if p.x < -20 || p.y < -20 || p.x > screenSize.width + 20 || p.y > screenSize.height + 20 { continue }
                let tw = 0.5 + 0.5 * sin((twinklePhase + s.twinklePhase) * 2 * .pi)
                let isTargetStar = ts.contains(s.id)

                // Hint pulse ring.
                if s.id == hintStarId {
                    let pulse = 0.5 + 0.5 * sin(hintPulse * 2 * .pi * 1.2)
                    let rr = 10 + pulse * 9
                    ctx.stroke(Path(ellipseIn: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)),
                               with: .color(accent.opacity(0.4 + 0.4 * pulse)), lineWidth: 1.6)
                }

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
                } else if isTargetStar {
                    // Mark target stars distinctly so the player can find them.
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 5.2, y: p.y - 5.2, width: 10.4, height: 10.4)),
                             with: .color(accent.opacity(0.22)))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 3.0, y: p.y - 3.0, width: 6.0, height: 6.0)),
                             with: .color(WeaverTheme.starCore.opacity(0.95)))
                    ctx.stroke(Path(ellipseIn: CGRect(x: p.x - 6.5, y: p.y - 6.5, width: 13, height: 13)),
                               with: .color(accent.opacity(0.7)), lineWidth: 1.1)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { isPanning = false }
            }
    }

    private func clampOffset(_ offset: CGSize, screenSize: CGSize, worldSize: CGSize) -> CGSize {
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
                lastTappedId = nil
                return
            }
            let exists = edges.contains { ($0.a == last && $0.b == hit.id) || ($0.a == hit.id && $0.b == last) }
            if !exists {
                edges.append(WeaverEdge(a: last, b: hit.id))
            }
            if !selectedIds.contains(hit.id) { selectedIds.append(hit.id) }
            lastTappedId = hit.id
        } else {
            if !selectedIds.contains(hit.id) { selectedIds.append(hit.id) }
            lastTappedId = hit.id
        }

        // After any connection, check trace completion.
        if mode.target != nil { checkTraceCompletion() }
    }

    private func checkTraceCompletion() {
        guard let t = mode.target, !showDiscovered else { return }
        if remainingTargetKeys.isEmpty {
            store.markDiscovered(t.id)
            withAnimation(.easeOut(duration: 0.4)) { showDiscovered = true }
        }
    }

    // MARK: - Controls

    private var controlBar: some View {
        VStack(spacing: 10) {
            Text(guidanceText)
                .font(.system(size: 12))
                .foregroundColor(WeaverTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(WeaverTheme.panel.opacity(0.85))
                .clipShape(Capsule())

            if isTrace {
                traceProgressBar
            }

            HStack(spacing: 12) {
                actionButton(title: "Undo", enabled: !edges.isEmpty) { undo() }
                actionButton(title: "Clear", enabled: !edges.isEmpty || !selectedIds.isEmpty) { clearFigure() }
                hintButton
                if isTrace {
                    // No "Save" in trace mode — discovery is the goal.
                    Spacer().frame(width: 0)
                } else {
                    Button { showSaveSheet = true } label: {
                        Text("Save")
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

    private var traceProgressBar: some View {
        let total = mode.target?.edgeKeys.count ?? 0
        let drawn = drawnTargetKeys.count
        return HStack(spacing: 8) {
            Text("\(drawn) / \(total) lines")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(WeaverTheme.textSecondary)
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(WeaverTheme.panelRaised)
                    Capsule()
                        .fill(WeaverTheme.accent(mode.target?.hueIndex ?? 0))
                        .frame(width: total == 0 ? 0 : g.size.width * CGFloat(drawn) / CGFloat(total))
                }
            }
            .frame(height: 6)
        }
    }

    private var hintButton: some View {
        Button { giveHint() } label: {
            WeaverHintIcon(size: 20, color: WeaverTheme.skyTop)
                .frame(width: 46, height: 46)
                .background(WeaverTheme.line.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var guidanceText: String {
        if isTrace {
            if remainingTargetKeys.isEmpty { return "Pattern complete!" }
            if lastTappedId != nil {
                return "Follow the faint guide — tap the next marked star to connect."
            }
            return "Tap the marked stars and follow the faint guide lines."
        }
        if !edges.isEmpty || lastTappedId != nil {
            let n = edges.count
            if lastTappedId != nil {
                return "\(n) line\(n == 1 ? "" : "s") — tap another star to extend"
            }
            return "\(n) line\(n == 1 ? "" : "s") — tap a star to start a new strand"
        }
        return "Tap stars to connect them. Drag to explore the sky."
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

    // MARK: - Hint

    private func giveHint() {
        if let t = mode.target {
            // Trace: pulse an endpoint of the next missing edge (prefer one
            // connected to the current chain so it flows naturally).
            let ts = targetStarIds
            let remaining = remainingTargetKeys
            guard let nextKey = remaining.sorted().first else {
                // All drawn — pulse any target star.
                hintStarId = ts.first; hintPulse = 0; return
            }
            // Parse the "lo-hi" key back into ids.
            let parts = nextKey.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 2 else { return }
            let a = parts[0], b = parts[1]
            // Prefer the endpoint that continues the current chain.
            if let last = lastTappedId, last == a || last == b {
                hintStarId = (last == a) ? b : a
            } else {
                hintStarId = a
            }
            hintPulse = 0
        } else {
            // Free mode: pulse a bright star (or one near the last tapped).
            if let last = lastTappedId, let ls = sky.stars.first(where: { $0.id == last }) {
                // nearest other star to extend toward
                var best: (id: Int, d: CGFloat)? = nil
                for s in sky.stars where s.id != last {
                    let dx = s.x - ls.x, dy = s.y - ls.y
                    let d = dx * dx + dy * dy
                    if best == nil || d < best!.d { best = (s.id, d) }
                }
                hintStarId = best?.id
            } else {
                // brightest star = good starting point
                hintStarId = sky.stars.max(by: { $0.magnitude < $1.magnitude })?.id
            }
            hintPulse = 0
        }
    }

    // MARK: - Discovered overlay

    private func discoveredOverlay(_ t: WeaverTarget) -> some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 16) {
                WeaverCheckIcon(size: 40, color: WeaverTheme.accent(t.hueIndex))
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(WeaverTheme.panelRaised))
                Text("Discovered")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WeaverTheme.textFaint)
                Text(t.name)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
                Text(t.fact)
                    .font(.system(size: 14))
                    .foregroundColor(WeaverTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                HStack(spacing: 12) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Text("Back to Trace")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(WeaverTheme.textPrimary)
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(WeaverTheme.panelRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    if let next = nextUndiscoveredTarget(after: t) {
                        Button {
                            onDiscovered?(next)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Next")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(WeaverTheme.skyTop)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(WeaverTheme.line)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
            .background(WeaverTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
            .padding(.horizontal, 28)
        }
    }

    private func nextUndiscoveredTarget(after t: WeaverTarget) -> WeaverTarget? {
        let all = WeaverConstellationCatalog.targets
        guard let idx = all.firstIndex(of: t) else { return nil }
        for i in 1...all.count {
            let cand = all[(idx + i) % all.count]
            if cand.id != t.id && !store.isDiscovered(cand.id) { return cand }
        }
        return nil
    }

    // MARK: - Edits

    private func undo() {
        guard !edges.isEmpty else { return }
        let removed = edges.removeLast()
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
