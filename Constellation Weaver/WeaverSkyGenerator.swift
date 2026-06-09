import Foundation
import CoreGraphics

// Deterministic pseudo-random generator (SplitMix64) so a sky seed always
// regenerates the exact same star field. No physics — pure placement math.
struct WeaverRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E3779B97F4A7C15 }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    // 0...1
    mutating func unit() -> CGFloat {
        CGFloat(next() >> 11) / CGFloat(UInt64(1) << 53)
    }

    mutating func range(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        lo + (hi - lo) * unit()
    }
}

enum WeaverSkyGenerator {

    // Curated region names so unlocked skies feel distinct & poetic.
    static let regionNames: [String] = [
        "Quiet Meadow Sky",
        "Northern Drift",
        "Amber Horizon",
        "Deep Veil Expanse",
        "Silver Tide Field",
        "Ember Hollow Sky",
        "Frostlight Reach",
        "Twilight Garden",
        "Harvest Lantern Sky",
        "Glacier Mirror Field",
        "Rosefall Expanse",
        "Midnight Orchard"
    ]

    static func generate(id: Int) -> WeaverSky {
        let seed = UInt64(bitPattern: Int64(0x00C0FFEE) &+ (Int64(id) &* 2654435761))
        var rng = WeaverRandom(seed: seed)
        let count = 70 + Int(rng.unit() * 40)   // 70...110 stars
        var stars: [WeaverStar] = []
        stars.reserveCapacity(count)
        for i in 0..<count {
            let x = rng.range(0.05, 0.95)
            let y = rng.range(0.05, 0.95)
            // Bias magnitude so most stars are faint, a few are bright.
            let raw = rng.unit()
            let mag = raw * raw            // skew toward dim
            let phase = rng.unit()
            stars.append(WeaverStar(id: i, x: x, y: y, magnitude: mag, twinklePhase: phase))
        }
        let name = regionNames[id % regionNames.count]
        return WeaverSky(id: id, name: name, seed: seed, hueIndex: id % 4, stars: stars)
    }
}
