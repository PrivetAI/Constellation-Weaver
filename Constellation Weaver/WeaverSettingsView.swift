import SwiftUI

struct WeaverSettingsView: View {
    @EnvironmentObject var store: WeaverStore
    @State private var showPrivacy = false

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    // Header card
                    VStack(spacing: 12) {
                        WeaverGlyphIcon(size: 64, color: WeaverTheme.line)
                        Text("Constellation Weaver")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundColor(WeaverTheme.textPrimary)
                        Text("A calm place to connect stars\nand collect your own night sky.")
                            .font(.system(size: 14))
                            .foregroundColor(WeaverTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(WeaverTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))

                    // Stats
                    VStack(spacing: 0) {
                        statRow(label: "Constellations woven", value: "\(store.totalCount)")
                        divider
                        statRow(label: "Skies revealed", value: "\(store.unlockedSkyCount) of \(WeaverStore.maxSkies)")
                    }
                    .background(WeaverTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))

                    // Privacy
                    VStack(spacing: 0) {
                        Button { showPrivacy = true } label: {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(size: 16))
                                    .foregroundColor(WeaverTheme.textPrimary)
                                Spacer()
                                WeaverChevron()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .background(WeaverTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))

                    Text("How to weave")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(WeaverTheme.textFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {
                        tip("Open a sky and drag to explore the star field.")
                        tip("Tap a star, then tap another to draw a line between them.")
                        tip("Tap the same star again to lift your pen and start a new strand.")
                        tip("Name your finished figure to save it into the atlas.")
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WeaverTheme.panel.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Version 1.0")
                        .font(.system(size: 12))
                        .foregroundColor(WeaverTheme.textFaint)
                        .padding(.top, 4)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
        .sheet(isPresented: $showPrivacy) {
            WeaverWebPanel(urlString: "https://constellationweaver.org/click.php")
        }
    }

    private var divider: some View {
        Rectangle().fill(WeaverTheme.stroke.opacity(0.5)).frame(height: 1).padding(.leading, 16)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 16)).foregroundColor(WeaverTheme.textPrimary)
            Spacer()
            Text(value).font(.system(size: 16, weight: .semibold)).foregroundColor(WeaverTheme.line)
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
    }

    private func tip(_ s: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(WeaverTheme.line).frame(width: 5, height: 5).padding(.top, 7)
            Text(s).font(.system(size: 14)).foregroundColor(WeaverTheme.textSecondary)
        }
    }
}

private struct WeaverChevron: View {
    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: 4, y: 2))
            p.addLine(to: CGPoint(x: 10, y: 8))
            p.addLine(to: CGPoint(x: 4, y: 14))
        }
        .stroke(WeaverTheme.textFaint, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 14, height: 16)
    }
}
