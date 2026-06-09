import Foundation
import CoreGraphics

// A target constellation the player can trace: a stable string id, a display
// name, normalized [0,1] star points, the canonical edge list (pairs of point
// indices), a one-line fact, and a hue index for its accent color.
//
// Coordinates are roughly arranged to resemble each real constellation. The
// exact astronomy is stylized for a calm tracing experience — the goal is a
// recognizable, pleasant figure to draw, not survey-grade accuracy.
struct WeaverTarget: Identifiable, Equatable {
    let id: String                 // stable string id (persistence key)
    let name: String
    let points: [CGPoint]          // normalized 0...1 within the figure's box
    let edges: [(Int, Int)]        // index pairs into `points`
    let fact: String
    let hueIndex: Int

    static func == (lhs: WeaverTarget, rhs: WeaverTarget) -> Bool { lhs.id == rhs.id }

    // Order-independent canonical edge keys ("min-max") for matching player edges.
    var edgeKeys: Set<String> {
        Set(edges.map { Self.key($0.0, $0.1) })
    }

    static func key(_ a: Int, _ b: Int) -> String {
        let lo = min(a, b), hi = max(a, b)
        return "\(lo)-\(hi)"
    }
}

enum WeaverConstellationCatalog {

    static let targets: [WeaverTarget] = [
        WeaverTarget(
            id: "orion",
            name: "Orion",
            points: [
                CGPoint(x: 0.30, y: 0.10), // Betelgeuse (shoulder)
                CGPoint(x: 0.68, y: 0.14), // Bellatrix (shoulder)
                CGPoint(x: 0.42, y: 0.46), // belt left
                CGPoint(x: 0.52, y: 0.50), // belt mid
                CGPoint(x: 0.62, y: 0.54), // belt right
                CGPoint(x: 0.26, y: 0.86), // Rigel (foot)
                CGPoint(x: 0.74, y: 0.82)  // Saiph (foot)
            ],
            edges: [(0, 2), (1, 4), (2, 3), (3, 4), (2, 5), (4, 6), (0, 1)],
            fact: "Orion the Hunter is anchored by the three bright stars of his belt.",
            hueIndex: 0),

        WeaverTarget(
            id: "ursa_major",
            name: "Ursa Major",
            points: [
                CGPoint(x: 0.10, y: 0.30), // bowl
                CGPoint(x: 0.30, y: 0.22),
                CGPoint(x: 0.34, y: 0.46),
                CGPoint(x: 0.14, y: 0.54),
                CGPoint(x: 0.54, y: 0.40), // handle
                CGPoint(x: 0.74, y: 0.52),
                CGPoint(x: 0.90, y: 0.70)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 0), (2, 4), (4, 5), (5, 6)],
            fact: "Its seven bright stars form the Plough, or Big Dipper.",
            hueIndex: 0),

        WeaverTarget(
            id: "cassiopeia",
            name: "Cassiopeia",
            points: [
                CGPoint(x: 0.10, y: 0.40),
                CGPoint(x: 0.32, y: 0.62),
                CGPoint(x: 0.52, y: 0.36),
                CGPoint(x: 0.72, y: 0.64),
                CGPoint(x: 0.92, y: 0.42)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4)],
            fact: "This vain queen traces a distinctive W across the northern sky.",
            hueIndex: 2),

        WeaverTarget(
            id: "leo",
            name: "Leo",
            points: [
                CGPoint(x: 0.18, y: 0.30), // sickle / head
                CGPoint(x: 0.26, y: 0.18),
                CGPoint(x: 0.40, y: 0.22),
                CGPoint(x: 0.34, y: 0.46),
                CGPoint(x: 0.30, y: 0.66), // Regulus
                CGPoint(x: 0.62, y: 0.50), // body
                CGPoint(x: 0.86, y: 0.42), // Denebola (tail)
                CGPoint(x: 0.66, y: 0.70)
            ],
            edges: [(1, 2), (2, 0), (0, 3), (3, 4), (3, 5), (5, 6), (5, 7), (4, 7)],
            fact: "Leo the Lion is crowned by a hook of stars called the Sickle.",
            hueIndex: 1),

        WeaverTarget(
            id: "cygnus",
            name: "Cygnus",
            points: [
                CGPoint(x: 0.50, y: 0.10), // Deneb (tail)
                CGPoint(x: 0.50, y: 0.40), // center
                CGPoint(x: 0.50, y: 0.86), // Albireo (beak)
                CGPoint(x: 0.16, y: 0.30), // wing
                CGPoint(x: 0.84, y: 0.54)  // wing
            ],
            edges: [(0, 1), (1, 2), (3, 1), (1, 4)],
            fact: "The Swan flies along the Milky Way, forming the Northern Cross.",
            hueIndex: 3),

        WeaverTarget(
            id: "lyra",
            name: "Lyra",
            points: [
                CGPoint(x: 0.40, y: 0.12), // Vega
                CGPoint(x: 0.62, y: 0.28),
                CGPoint(x: 0.34, y: 0.40),
                CGPoint(x: 0.42, y: 0.72),
                CGPoint(x: 0.70, y: 0.62)
            ],
            edges: [(0, 1), (0, 2), (2, 3), (3, 4), (4, 1)],
            fact: "Lyra holds Vega, one of the brightest stars in the night sky.",
            hueIndex: 2),

        WeaverTarget(
            id: "scorpius",
            name: "Scorpius",
            points: [
                CGPoint(x: 0.16, y: 0.16), // claws
                CGPoint(x: 0.34, y: 0.24),
                CGPoint(x: 0.30, y: 0.40), // Antares (heart)
                CGPoint(x: 0.40, y: 0.58),
                CGPoint(x: 0.54, y: 0.72),
                CGPoint(x: 0.72, y: 0.74),
                CGPoint(x: 0.84, y: 0.60) // stinger
            ],
            edges: [(0, 2), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6)],
            fact: "The Scorpion's red heart is the supergiant star Antares.",
            hueIndex: 1),

        WeaverTarget(
            id: "gemini",
            name: "Gemini",
            points: [
                CGPoint(x: 0.32, y: 0.12), // Castor head
                CGPoint(x: 0.66, y: 0.16), // Pollux head
                CGPoint(x: 0.28, y: 0.44),
                CGPoint(x: 0.62, y: 0.46),
                CGPoint(x: 0.24, y: 0.80), // feet
                CGPoint(x: 0.58, y: 0.82)
            ],
            edges: [(0, 2), (1, 3), (2, 3), (2, 4), (3, 5)],
            fact: "The Twins Castor and Pollux stand side by side in the winter sky.",
            hueIndex: 0),

        WeaverTarget(
            id: "taurus",
            name: "Taurus",
            points: [
                CGPoint(x: 0.20, y: 0.20), // horn tip
                CGPoint(x: 0.40, y: 0.40),
                CGPoint(x: 0.52, y: 0.54), // Aldebaran
                CGPoint(x: 0.36, y: 0.66),
                CGPoint(x: 0.66, y: 0.66),
                CGPoint(x: 0.84, y: 0.24)  // horn tip
            ],
            edges: [(0, 1), (1, 2), (2, 4), (2, 3), (4, 5)],
            fact: "The Bull's face is the V-shaped Hyades, lit by orange Aldebaran.",
            hueIndex: 1),

        WeaverTarget(
            id: "crux",
            name: "Crux",
            points: [
                CGPoint(x: 0.50, y: 0.10), // top
                CGPoint(x: 0.50, y: 0.86), // bottom
                CGPoint(x: 0.18, y: 0.50), // left
                CGPoint(x: 0.82, y: 0.46)  // right
            ],
            edges: [(0, 1), (2, 3)],
            fact: "The Southern Cross is the smallest of all 88 constellations.",
            hueIndex: 3),

        WeaverTarget(
            id: "aquila",
            name: "Aquila",
            points: [
                CGPoint(x: 0.50, y: 0.14), // Altair area
                CGPoint(x: 0.36, y: 0.30),
                CGPoint(x: 0.64, y: 0.30),
                CGPoint(x: 0.50, y: 0.52),
                CGPoint(x: 0.30, y: 0.74),
                CGPoint(x: 0.70, y: 0.78)
            ],
            edges: [(1, 0), (0, 2), (0, 3), (3, 4), (3, 5)],
            fact: "The Eagle carries bright Altair, a corner of the Summer Triangle.",
            hueIndex: 0),

        WeaverTarget(
            id: "draco",
            name: "Draco",
            points: [
                CGPoint(x: 0.16, y: 0.80), // tail
                CGPoint(x: 0.34, y: 0.60),
                CGPoint(x: 0.30, y: 0.36),
                CGPoint(x: 0.52, y: 0.24),
                CGPoint(x: 0.70, y: 0.34),
                CGPoint(x: 0.80, y: 0.16), // head
                CGPoint(x: 0.66, y: 0.12)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 4)],
            fact: "The Dragon coils between the two Bears near the north pole.",
            hueIndex: 3),

        WeaverTarget(
            id: "bootes",
            name: "Bootes",
            points: [
                CGPoint(x: 0.50, y: 0.84), // Arcturus
                CGPoint(x: 0.34, y: 0.56),
                CGPoint(x: 0.66, y: 0.56),
                CGPoint(x: 0.28, y: 0.28),
                CGPoint(x: 0.58, y: 0.22),
                CGPoint(x: 0.74, y: 0.34)
            ],
            edges: [(0, 1), (0, 2), (1, 3), (3, 4), (4, 5), (5, 2)],
            fact: "The Herdsman is led by Arcturus, a brilliant orange giant.",
            hueIndex: 1),

        WeaverTarget(
            id: "perseus",
            name: "Perseus",
            points: [
                CGPoint(x: 0.46, y: 0.12), // head
                CGPoint(x: 0.52, y: 0.36),
                CGPoint(x: 0.38, y: 0.54),
                CGPoint(x: 0.62, y: 0.58),
                CGPoint(x: 0.28, y: 0.78), // leg
                CGPoint(x: 0.78, y: 0.80)  // leg
            ],
            edges: [(0, 1), (1, 2), (1, 3), (2, 4), (3, 5)],
            fact: "Perseus the Hero holds Algol, the famous winking Demon Star.",
            hueIndex: 2)
    ]

    static func target(id: String) -> WeaverTarget? {
        targets.first { $0.id == id }
    }

    static var count: Int { targets.count }
}
