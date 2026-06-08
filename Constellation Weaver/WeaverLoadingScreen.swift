import SwiftUI

struct WeaverLoadingScreen: View {
    @State private var twinkle = false

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            // A few decorative background stars.
            GeometryReader { geo in
                ForEach(0..<26, id: \.self) { i in
                    let seed = Double((i &* 2654435761) % 1000) / 1000.0
                    let seed2 = Double((i &* 40503) % 1000) / 1000.0
                    Circle()
                        .fill(WeaverTheme.starCore)
                        .frame(width: 1.5 + CGFloat(seed) * 2.2,
                               height: 1.5 + CGFloat(seed) * 2.2)
                        .opacity(twinkle ? 0.25 + seed2 * 0.6 : 0.15)
                        .position(x: CGFloat(seed) * geo.size.width,
                                  y: CGFloat(seed2) * geo.size.height)
                }
            }

            VStack(spacing: 22) {
                WeaverGlyphIcon(size: 92, color: WeaverTheme.line)
                    .opacity(twinkle ? 1.0 : 0.55)
                Text("Constellation Weaver")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
                Text("Gathering the night sky")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(WeaverTheme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                twinkle = true
            }
        }
    }
}
