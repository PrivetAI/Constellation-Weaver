import Foundation
import CoreGraphics

// MARK: - Star (a point in a sky region)

struct WeaverStar: Codable, Identifiable, Equatable {
    let id: Int           // stable index within a sky region
    let x: CGFloat        // normalized 0...1 within the region's world space
    let y: CGFloat
    let magnitude: CGFloat    // 0...1 — drives base brightness & size
    let twinklePhase: CGFloat // 0...1 — offset so stars twinkle out of sync
}

// MARK: - Sky region (a generated canvas of stars)

struct WeaverSky: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let seed: UInt64
    let hueIndex: Int
    var stars: [WeaverStar]
}

// MARK: - A saved constellation (line graph over star ids)

struct WeaverEdge: Codable, Equatable {
    let a: Int
    let b: Int
}

struct WeaverConstellation: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var note: String
    var skyId: Int
    var skyName: String
    var hueIndex: Int
    var createdAt: Date
    // Captured snapshot of the stars used, so a saved figure is fully
    // self-contained and re-viewable.
    var stars: [WeaverStar]
    var edges: [WeaverEdge]

    init(id: UUID = UUID(),
         name: String,
         note: String,
         skyId: Int,
         skyName: String,
         hueIndex: Int,
         createdAt: Date = Date(),
         stars: [WeaverStar],
         edges: [WeaverEdge]) {
        self.id = id
        self.name = name
        self.note = note
        self.skyId = skyId
        self.skyName = skyName
        self.hueIndex = hueIndex
        self.createdAt = createdAt
        self.stars = stars
        self.edges = edges
    }
}
