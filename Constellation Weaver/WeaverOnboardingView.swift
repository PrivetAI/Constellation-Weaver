import SwiftUI

// A short, skippable guided overlay shown on first launch (and replayable from
// Settings). Pure SwiftUI + custom shapes — no system components, no emoji.
struct WeaverOnboardingView: View {
    let onFinish: () -> Void

    @State private var step = 0
    @State private var twinkle = false

    private struct Page {
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(title: "Tap a star",
             body: "Open a sky and tap any star to begin. Drag empty space to pan around the field."),
        Page(title: "Connect the dots",
             body: "Tap a second star to draw a line between them. Keep tapping to weave a shape. Tap the same star to lift your pen."),
        Page(title: "Name & keep it",
             body: "Happy with your figure? Save it with a name and it joins your atlas to revisit any time."),
        Page(title: "Discover real ones",
             body: "Visit the Trace tab to find famous constellations like Orion and Leo. Follow the faint guide to discover and collect them all.")
    ]

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            // Decorative twinkle field.
            GeometryReader { geo in
                ForEach(0..<30, id: \.self) { i in
                    let s = Double((i &* 2654435761) % 1000) / 1000.0
                    let s2 = Double((i &* 40503) % 1000) / 1000.0
                    Circle()
                        .fill(WeaverTheme.starCore)
                        .frame(width: 1.4 + CGFloat(s) * 2.0, height: 1.4 + CGFloat(s) * 2.0)
                        .opacity(twinkle ? 0.2 + s2 * 0.55 : 0.12)
                        .position(x: CGFloat(s) * geo.size.width, y: CGFloat(s2) * geo.size.height)
                }
            }

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: finish) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(WeaverTheme.textFaint)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)

                Spacer()

                illustration
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 28)

                Text(pages[step].title)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                Text(pages[step].body)
                    .font(.system(size: 16))
                    .foregroundColor(WeaverTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 36)

                Spacer()

                // Page dots.
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? WeaverTheme.line : WeaverTheme.stroke)
                            .frame(width: i == step ? 9 : 7, height: i == step ? 9 : 7)
                    }
                }
                .padding(.bottom, 22)

                Button(action: advance) {
                    Text(step == pages.count - 1 ? "Start weaving" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(WeaverTheme.skyTop)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(WeaverTheme.line)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { twinkle = true }
        }
    }

    // A small constellation-style illustration that changes per step.
    private var illustration: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let accent = WeaverTheme.accent(step % 4)
            // A simple, distinct figure per page.
            let figures: [[CGPoint]] = [
                [CGPoint(x: 0.5, y: 0.5)],                                              // single star
                [CGPoint(x: 0.25, y: 0.7), CGPoint(x: 0.6, y: 0.35)],                   // two connected
                [CGPoint(x: 0.2, y: 0.7), CGPoint(x: 0.5, y: 0.3), CGPoint(x: 0.8, y: 0.6)], // strand
                [CGPoint(x: 0.3, y: 0.2), CGPoint(x: 0.65, y: 0.28), CGPoint(x: 0.45, y: 0.55),
                 CGPoint(x: 0.7, y: 0.72), CGPoint(x: 0.28, y: 0.66)]                   // constellation
            ]
            let pts = figures[min(step, figures.count - 1)].map { CGPoint(x: $0.x * w, y: $0.y * h) }
            ZStack {
                Circle().fill(WeaverTheme.panel.opacity(0.5))
                    .overlay(Circle().stroke(WeaverTheme.stroke.opacity(0.5), lineWidth: 1))
                if pts.count > 1 {
                    Path { p in
                        p.move(to: pts[0])
                        for i in 1..<pts.count { p.addLine(to: pts[i]) }
                    }
                    .stroke(accent.opacity(0.8), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                ForEach(0..<pts.count, id: \.self) { i in
                    Circle().fill(accent.opacity(0.2)).frame(width: 16, height: 16).position(pts[i])
                    Circle().fill(WeaverTheme.starCore).frame(width: 7, height: 7).position(pts[i])
                }
            }
        }
    }

    private func advance() {
        if step < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
        } else {
            finish()
        }
    }

    private func finish() { onFinish() }
}
