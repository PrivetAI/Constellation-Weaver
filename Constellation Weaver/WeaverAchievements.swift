import Foundation

// A single achievement: a stable string id, title, blurb, and a predicate that
// decides — from the current store state — whether it should be unlocked.
struct WeaverAchievement: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let isEarned: (WeaverProgressSnapshot) -> Bool

    static func == (lhs: WeaverAchievement, rhs: WeaverAchievement) -> Bool { lhs.id == rhs.id }
}

// A plain snapshot of the numbers achievements care about, so the catalog stays
// free of any reference to the store type.
struct WeaverProgressSnapshot {
    let savedFigures: Int
    let discoveredConstellations: Int
    let totalConstellations: Int
    let skiesRevealed: Int
}

enum WeaverAchievementsCatalog {

    static let all: [WeaverAchievement] = [
        WeaverAchievement(
            id: "first_trace",
            title: "First Light",
            detail: "Discover your first constellation in Trace mode.",
            isEarned: { $0.discoveredConstellations >= 1 }),

        WeaverAchievement(
            id: "trace_five",
            title: "Star Reader",
            detail: "Discover five constellations.",
            isEarned: { $0.discoveredConstellations >= 5 }),

        WeaverAchievement(
            id: "trace_all",
            title: "Celestial Cartographer",
            detail: "Discover every constellation in the catalog.",
            isEarned: { $0.discoveredConstellations >= $0.totalConstellations && $0.totalConstellations > 0 }),

        WeaverAchievement(
            id: "first_figure",
            title: "First Strand",
            detail: "Save your first free figure to the atlas.",
            isEarned: { $0.savedFigures >= 1 }),

        WeaverAchievement(
            id: "ten_figures",
            title: "Weaver's Hand",
            detail: "Save ten free figures.",
            isEarned: { $0.savedFigures >= 10 }),

        WeaverAchievement(
            id: "explore_skies",
            title: "Sky Wanderer",
            detail: "Reveal at least five night skies.",
            isEarned: { $0.skiesRevealed >= 5 })
    ]

    static func achievement(id: String) -> WeaverAchievement? {
        all.first { $0.id == id }
    }

    static var count: Int { all.count }
}
