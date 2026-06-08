import SwiftUI

struct WeaverAtlasView: View {
    @EnvironmentObject var store: WeaverStore

    private let columns = [GridItem(.adaptive(minimum: 165), spacing: 14)]

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            if store.constellations.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("\(store.totalCount) constellation\(store.totalCount == 1 ? "" : "s") collected")
                            .font(.system(size: 14))
                            .foregroundColor(WeaverTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.constellations) { c in
                                NavigationLink {
                                    WeaverDetailView(constellation: c)
                                } label: {
                                    WeaverAtlasCard(constellation: c)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sky Atlas")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            WeaverGlyphIcon(size: 72, color: WeaverTheme.textFaint)
            Text("Your atlas is empty")
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .foregroundColor(WeaverTheme.textPrimary)
            Text("Visit the Skies tab, connect a few stars,\nand save your first constellation.")
                .font(.system(size: 14))
                .foregroundColor(WeaverTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

private struct WeaverAtlasCard: View {
    let constellation: WeaverConstellation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(WeaverTheme.skyTop)
                WeaverFigureView(stars: constellation.stars,
                                 edges: constellation.edges,
                                 hueIndex: constellation.hueIndex,
                                 showAllStars: false)
                    .padding(14)
            }
            .frame(height: 130)

            VStack(alignment: .leading, spacing: 3) {
                Text(constellation.name)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(WeaverTheme.textPrimary)
                    .lineLimit(1)
                Text(constellation.skyName)
                    .font(.system(size: 12))
                    .foregroundColor(WeaverTheme.textFaint)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}
