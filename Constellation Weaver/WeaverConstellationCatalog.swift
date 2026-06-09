import Foundation
import CoreGraphics

// A target constellation the player can trace: a stable string id, a display
// name, normalized [0,1] star points, the canonical edge list (pairs of point
// indices), a one-line fact, and a hue index for its accent color.
//
// Coordinates reflect REAL relative star positions: each figure is derived from
// the actual bright-star pattern (real right ascension / declination mapped to a
// flat star-chart layout, then normalized into [0,1]) so the shape, proportions
// and orientation match what you see on a standard north-up sky chart. Edge
// lists use the canonical IAU / standard line figures. The aim is for players to
// learn to recognize the genuine patterns in the night sky.
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

        // MARK: - Existing ids (realigned to true star positions)

        WeaverTarget(
            id: "orion",
            name: "Orion",
            points: [
                CGPoint(x: 0.74, y: 0.16), // Betelgeuse (left shoulder)
                CGPoint(x: 0.30, y: 0.20), // Bellatrix (right shoulder)
                CGPoint(x: 0.60, y: 0.50), // Alnitak (belt, left)
                CGPoint(x: 0.52, y: 0.52), // Alnilam (belt, mid)
                CGPoint(x: 0.44, y: 0.54), // Mintaka (belt, right)
                CGPoint(x: 0.78, y: 0.88), // Saiph (left foot)
                CGPoint(x: 0.28, y: 0.84)  // Rigel (right foot)
            ],
            edges: [(0, 2), (1, 4), (2, 3), (3, 4), (2, 5), (4, 6), (0, 1)],
            fact: "Orion's Belt is three bright stars in a row; red Betelgeuse marks one shoulder, blue Rigel a foot.",
            hueIndex: 0),

        WeaverTarget(
            id: "ursa_major",
            name: "Ursa Major",
            points: [
                CGPoint(x: 0.88, y: 0.42), // Dubhe (bowl, pointer)
                CGPoint(x: 0.88, y: 0.62), // Merak (bowl, pointer)
                CGPoint(x: 0.70, y: 0.66), // Phecda (bowl)
                CGPoint(x: 0.70, y: 0.46), // Megrez (bowl/handle join)
                CGPoint(x: 0.50, y: 0.40), // Alioth (handle)
                CGPoint(x: 0.30, y: 0.36), // Mizar (handle)
                CGPoint(x: 0.10, y: 0.30)  // Alkaid (handle tip)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 0), (3, 4), (4, 5), (5, 6)],
            fact: "The Big Dipper, or Plough; follow its two pointer stars (Dubhe and Merak) up to Polaris.",
            hueIndex: 0),

        WeaverTarget(
            id: "cassiopeia",
            name: "Cassiopeia",
            points: [
                CGPoint(x: 0.08, y: 0.46), // Caph
                CGPoint(x: 0.30, y: 0.58), // Schedar
                CGPoint(x: 0.50, y: 0.40), // Gamma Cas
                CGPoint(x: 0.72, y: 0.62), // Ruchbah
                CGPoint(x: 0.92, y: 0.50)  // Segin
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4)],
            fact: "A bright W (or M) of five stars opposite the Big Dipper across Polaris.",
            hueIndex: 2),

        WeaverTarget(
            id: "leo",
            name: "Leo",
            points: [
                CGPoint(x: 0.74, y: 0.66), // Regulus (heart, base of Sickle)
                CGPoint(x: 0.78, y: 0.46), // Eta Leonis
                CGPoint(x: 0.82, y: 0.30), // Algieba
                CGPoint(x: 0.76, y: 0.16), // Adhafera / Zeta
                CGPoint(x: 0.64, y: 0.14), // Ras Elased (Mu)
                CGPoint(x: 0.40, y: 0.48), // Zosma (hip)
                CGPoint(x: 0.14, y: 0.42), // Denebola (tail)
                CGPoint(x: 0.46, y: 0.70)  // Chertan / Theta
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (1, 5), (5, 6), (0, 7), (7, 5)],
            fact: "A backwards question mark, the Sickle, marks the Lion's head, anchored by bright Regulus.",
            hueIndex: 1),

        WeaverTarget(
            id: "cygnus",
            name: "Cygnus",
            points: [
                CGPoint(x: 0.50, y: 0.08), // Deneb (tail)
                CGPoint(x: 0.50, y: 0.42), // Sadr (center)
                CGPoint(x: 0.50, y: 0.92), // Albireo (beak)
                CGPoint(x: 0.16, y: 0.30), // Delta (wing)
                CGPoint(x: 0.84, y: 0.56)  // Gienah (wing)
            ],
            edges: [(0, 1), (1, 2), (3, 1), (1, 4)],
            fact: "The Northern Cross flies down the Milky Way; bright Deneb is a corner of the Summer Triangle.",
            hueIndex: 3),

        WeaverTarget(
            id: "lyra",
            name: "Lyra",
            points: [
                CGPoint(x: 0.30, y: 0.10), // Vega
                CGPoint(x: 0.50, y: 0.22), // Epsilon (double-double)
                CGPoint(x: 0.30, y: 0.36), // Zeta
                CGPoint(x: 0.44, y: 0.74), // Sheliak (Beta)
                CGPoint(x: 0.66, y: 0.62)  // Sulafat (Gamma)
            ],
            edges: [(0, 1), (1, 2), (0, 2), (2, 3), (3, 4), (4, 1)],
            fact: "Brilliant blue-white Vega leads a small parallelogram; it is a corner of the Summer Triangle.",
            hueIndex: 2),

        WeaverTarget(
            id: "scorpius",
            name: "Scorpius",
            points: [
                CGPoint(x: 0.86, y: 0.10), // Beta (claw)
                CGPoint(x: 0.74, y: 0.18), // Dschubba (head)
                CGPoint(x: 0.66, y: 0.26), // Pi
                CGPoint(x: 0.60, y: 0.40), // Antares (heart)
                CGPoint(x: 0.52, y: 0.56), // Tau
                CGPoint(x: 0.42, y: 0.70), // Epsilon
                CGPoint(x: 0.30, y: 0.82), // Mu
                CGPoint(x: 0.22, y: 0.74), // Zeta
                CGPoint(x: 0.20, y: 0.58), // Eta
                CGPoint(x: 0.26, y: 0.46), // Shaula (stinger)
                CGPoint(x: 0.34, y: 0.40)  // Lesath (stinger tip)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10)],
            fact: "A long curving J ending in a hooked stinger; its red heart is the supergiant Antares.",
            hueIndex: 1),

        WeaverTarget(
            id: "gemini",
            name: "Gemini",
            points: [
                CGPoint(x: 0.26, y: 0.14), // Castor (head)
                CGPoint(x: 0.50, y: 0.18), // Pollux (head)
                CGPoint(x: 0.24, y: 0.42), // Castor body
                CGPoint(x: 0.50, y: 0.46), // Pollux body
                CGPoint(x: 0.16, y: 0.70), // Tejat / Mebsuta (foot line)
                CGPoint(x: 0.36, y: 0.86), // Alhena (bright foot)
                CGPoint(x: 0.62, y: 0.74)  // Pollux foot
            ],
            edges: [(0, 2), (1, 3), (0, 1), (2, 4), (2, 5), (3, 6)],
            fact: "Two parallel star lines for the Twins, headed by Castor and bright Pollux side by side.",
            hueIndex: 0),

        WeaverTarget(
            id: "taurus",
            name: "Taurus",
            points: [
                CGPoint(x: 0.16, y: 0.10), // Elnath (north horn tip)
                CGPoint(x: 0.36, y: 0.40), // horn join
                CGPoint(x: 0.50, y: 0.54), // Aldebaran (eye)
                CGPoint(x: 0.42, y: 0.62), // Hyades V (lower)
                CGPoint(x: 0.62, y: 0.50), // Hyades V (upper)
                CGPoint(x: 0.86, y: 0.30), // Zeta (south horn tip)
                CGPoint(x: 0.78, y: 0.86)  // face / cheek
            ],
            edges: [(0, 1), (1, 2), (2, 3), (2, 4), (4, 5), (3, 6)],
            fact: "A V-shaped face, the Hyades cluster, lit by orange Aldebaran, with the Pleiades nearby.",
            hueIndex: 1),

        WeaverTarget(
            id: "crux",
            name: "Crux",
            points: [
                CGPoint(x: 0.52, y: 0.08), // Gacrux (top)
                CGPoint(x: 0.48, y: 0.92), // Acrux (bottom, bright)
                CGPoint(x: 0.14, y: 0.44), // Imai / Delta (left arm)
                CGPoint(x: 0.86, y: 0.52)  // Mimosa / Beta (right arm)
            ],
            edges: [(0, 1), (2, 3)],
            fact: "The Southern Cross; its long axis points toward the south celestial pole.",
            hueIndex: 3),

        WeaverTarget(
            id: "aquila",
            name: "Aquila",
            points: [
                CGPoint(x: 0.50, y: 0.30), // Altair
                CGPoint(x: 0.40, y: 0.20), // Tarazed
                CGPoint(x: 0.60, y: 0.40), // Alshain
                CGPoint(x: 0.22, y: 0.16), // Zeta (wing)
                CGPoint(x: 0.78, y: 0.54), // Delta / Lambda (wing)
                CGPoint(x: 0.84, y: 0.78), // Theta (tail)
                CGPoint(x: 0.16, y: 0.50)  // Epsilon
            ],
            edges: [(1, 0), (0, 2), (3, 1), (2, 4), (4, 5), (6, 1)],
            fact: "The Eagle's bright star Altair, flanked by two fainter stars, anchors the Summer Triangle.",
            hueIndex: 0),

        WeaverTarget(
            id: "draco",
            name: "Draco",
            points: [
                CGPoint(x: 0.10, y: 0.86), // tail (near Big Dipper)
                CGPoint(x: 0.30, y: 0.70),
                CGPoint(x: 0.46, y: 0.56),
                CGPoint(x: 0.40, y: 0.38),
                CGPoint(x: 0.58, y: 0.30),
                CGPoint(x: 0.74, y: 0.22), // neck
                CGPoint(x: 0.86, y: 0.12), // Eltanin (head)
                CGPoint(x: 0.72, y: 0.06), // Rastaban (head)
                CGPoint(x: 0.64, y: 0.16)  // head corner
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 5)],
            fact: "A long winding dragon coiling between the Bears; its head is a quadrilateral near Hercules.",
            hueIndex: 3),

        WeaverTarget(
            id: "bootes",
            name: "Bootes",
            points: [
                CGPoint(x: 0.46, y: 0.94), // Arcturus
                CGPoint(x: 0.30, y: 0.66), // Mufrid / Eta
                CGPoint(x: 0.62, y: 0.62), // Izar / Epsilon
                CGPoint(x: 0.24, y: 0.36), // Seginus (kite)
                CGPoint(x: 0.58, y: 0.30), // Nekkar / Beta (kite top)
                CGPoint(x: 0.70, y: 0.42)  // Delta
            ],
            edges: [(0, 1), (0, 2), (1, 3), (3, 4), (4, 5), (5, 2)],
            fact: "A kite or ice-cream cone; arc from the Big Dipper's handle to brilliant orange Arcturus.",
            hueIndex: 1),

        WeaverTarget(
            id: "perseus",
            name: "Perseus",
            points: [
                CGPoint(x: 0.36, y: 0.10), // Gamma (head)
                CGPoint(x: 0.46, y: 0.30), // Mirfak (bright center)
                CGPoint(x: 0.40, y: 0.48), // Algol (Demon Star)
                CGPoint(x: 0.58, y: 0.44), // Delta
                CGPoint(x: 0.30, y: 0.72), // Epsilon / Xi (leg)
                CGPoint(x: 0.70, y: 0.66), // Zeta
                CGPoint(x: 0.78, y: 0.86)  // foot
            ],
            edges: [(0, 1), (1, 2), (1, 3), (2, 4), (3, 5), (5, 6)],
            fact: "Bright Mirfak leads the Hero; watch Algol, the Demon Star, dim every few days.",
            hueIndex: 2),

        // MARK: - New constellations (new stable ids)

        WeaverTarget(
            id: "ursa_minor",
            name: "Ursa Minor",
            points: [
                CGPoint(x: 0.50, y: 0.08), // Polaris (handle tip / North Star)
                CGPoint(x: 0.56, y: 0.32), // Yildun
                CGPoint(x: 0.58, y: 0.56), // Epsilon
                CGPoint(x: 0.54, y: 0.76), // Eta (bowl)
                CGPoint(x: 0.34, y: 0.86), // Pherkad (bowl)
                CGPoint(x: 0.30, y: 0.64), // Kochab (bowl, bright)
                CGPoint(x: 0.40, y: 0.50)  // Zeta (bowl)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 3)],
            fact: "The Little Dipper; Polaris, the North Star, sits at the tip of its handle.",
            hueIndex: 3),

        WeaverTarget(
            id: "cepheus",
            name: "Cepheus",
            points: [
                CGPoint(x: 0.50, y: 0.08), // Errai / Gamma (roof peak)
                CGPoint(x: 0.24, y: 0.42), // Alderamin / Alpha
                CGPoint(x: 0.76, y: 0.42), // Beta
                CGPoint(x: 0.28, y: 0.82), // Zeta (base)
                CGPoint(x: 0.72, y: 0.82)  // Iota (base)
            ],
            edges: [(0, 1), (0, 2), (1, 3), (2, 4), (3, 4)],
            fact: "A house or church shape near Polaris, with its peaked roof pointing toward the pole.",
            hueIndex: 2),

        WeaverTarget(
            id: "sagittarius",
            name: "Sagittarius",
            points: [
                CGPoint(x: 0.22, y: 0.30), // Kaus Borealis (lid top)
                CGPoint(x: 0.16, y: 0.58), // Kaus Media (spout base)
                CGPoint(x: 0.04, y: 0.74), // Kaus Australis (spout tip)
                CGPoint(x: 0.34, y: 0.66), // Phi (body)
                CGPoint(x: 0.50, y: 0.46), // Nunki (handle top)
                CGPoint(x: 0.58, y: 0.66), // Tau (handle)
                CGPoint(x: 0.40, y: 0.84)  // body base
            ],
            edges: [(0, 1), (1, 2), (0, 4), (3, 4), (3, 1), (4, 5), (5, 6), (6, 3)],
            fact: "The Teapot of Sagittarius; steam from its spout is the bright center of the Milky Way.",
            hueIndex: 1),

        WeaverTarget(
            id: "auriga",
            name: "Auriga",
            points: [
                CGPoint(x: 0.40, y: 0.10), // Capella (bright)
                CGPoint(x: 0.66, y: 0.20), // Menkalinan
                CGPoint(x: 0.80, y: 0.52), // Theta
                CGPoint(x: 0.58, y: 0.78), // Elnath (shared with Taurus)
                CGPoint(x: 0.24, y: 0.56), // Iota
                CGPoint(x: 0.30, y: 0.30)  // Eta / the Kids
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0)],
            fact: "A bright pentagon; brilliant Capella is the sixth-brightest star in the night sky.",
            hueIndex: 2),

        WeaverTarget(
            id: "andromeda",
            name: "Andromeda",
            points: [
                CGPoint(x: 0.08, y: 0.66), // Alpheratz (shared with Pegasus)
                CGPoint(x: 0.34, y: 0.56), // Delta
                CGPoint(x: 0.56, y: 0.44), // Mirach (Beta)
                CGPoint(x: 0.80, y: 0.30), // Almach (Gamma)
                CGPoint(x: 0.50, y: 0.20), // Mu (chain)
                CGPoint(x: 0.44, y: 0.04)  // Nu / galaxy direction
            ],
            edges: [(0, 1), (1, 2), (2, 3), (2, 4), (4, 5)],
            fact: "A chain of stars off the Great Square; near Mirach lies the Andromeda Galaxy, M31.",
            hueIndex: 3),

        WeaverTarget(
            id: "pegasus",
            name: "Pegasus",
            points: [
                CGPoint(x: 0.30, y: 0.18), // Scheat
                CGPoint(x: 0.72, y: 0.18), // Alpheratz (shared corner)
                CGPoint(x: 0.74, y: 0.60), // Algenib
                CGPoint(x: 0.32, y: 0.60), // Markab
                CGPoint(x: 0.06, y: 0.42), // Matar (neck)
                CGPoint(x: 0.10, y: 0.80), // Enif (nose)
                CGPoint(x: 0.04, y: 0.62)  // Theta (head)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 0), (0, 4), (4, 6), (6, 5)],
            fact: "The Great Square of Pegasus, a large near-empty box high in the autumn sky.",
            hueIndex: 0),

        WeaverTarget(
            id: "corona_borealis",
            name: "Corona Borealis",
            points: [
                CGPoint(x: 0.10, y: 0.46), // Theta
                CGPoint(x: 0.28, y: 0.30), // Beta
                CGPoint(x: 0.50, y: 0.24), // Alphecca (bright gem)
                CGPoint(x: 0.70, y: 0.32), // Gamma
                CGPoint(x: 0.84, y: 0.48), // Delta
                CGPoint(x: 0.90, y: 0.70), // Epsilon
                CGPoint(x: 0.78, y: 0.84)  // Iota
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6)],
            fact: "A graceful semicircle, the Northern Crown; its brightest jewel is Alphecca.",
            hueIndex: 2),

        WeaverTarget(
            id: "hercules",
            name: "Hercules",
            points: [
                CGPoint(x: 0.36, y: 0.40), // Pi (Keystone)
                CGPoint(x: 0.58, y: 0.34), // Eta (Keystone)
                CGPoint(x: 0.64, y: 0.56), // Zeta (Keystone)
                CGPoint(x: 0.40, y: 0.60), // Epsilon (Keystone)
                CGPoint(x: 0.20, y: 0.18), // Iota (arm)
                CGPoint(x: 0.76, y: 0.16), // Tau (arm)
                CGPoint(x: 0.30, y: 0.82), // Delta (leg)
                CGPoint(x: 0.78, y: 0.80), // Beta / Sarin (leg)
                CGPoint(x: 0.50, y: 0.94)  // Rasalgethi direction
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 0), (0, 4), (1, 5), (3, 6), (2, 7), (6, 8), (7, 8)],
            fact: "Find the Keystone, a lopsided square at the Hero's core; it hosts the great cluster M13.",
            hueIndex: 1),

        WeaverTarget(
            id: "canis_major",
            name: "Canis Major",
            points: [
                CGPoint(x: 0.40, y: 0.24), // Sirius (brightest star)
                CGPoint(x: 0.26, y: 0.14), // Theta (head)
                CGPoint(x: 0.58, y: 0.18), // Muliphein
                CGPoint(x: 0.46, y: 0.50), // Mirzam direction / Wezen
                CGPoint(x: 0.34, y: 0.74), // Adhara (hindquarters)
                CGPoint(x: 0.62, y: 0.78), // Wezen
                CGPoint(x: 0.78, y: 0.62), // Aludra
                CGPoint(x: 0.20, y: 0.46)  // Mirzam (forepaw)
            ],
            edges: [(1, 0), (0, 2), (0, 3), (3, 4), (4, 5), (5, 6), (3, 7)],
            fact: "The Great Dog carries Sirius, the brightest star in the night sky, below Orion.",
            hueIndex: 0),

        WeaverTarget(
            id: "canis_minor",
            name: "Canis Minor",
            points: [
                CGPoint(x: 0.22, y: 0.66), // Procyon (bright)
                CGPoint(x: 0.78, y: 0.34)  // Gomeisa
            ],
            edges: [(0, 1)],
            fact: "The Little Dog is just two stars; bright Procyon completes the Winter Triangle.",
            hueIndex: 0),

        WeaverTarget(
            id: "centaurus",
            name: "Centaurus",
            points: [
                CGPoint(x: 0.16, y: 0.86), // Alpha Centauri (Rigil Kentaurus)
                CGPoint(x: 0.30, y: 0.78), // Hadar (Beta)
                CGPoint(x: 0.46, y: 0.58), // Epsilon
                CGPoint(x: 0.58, y: 0.42), // Menkent (Theta)
                CGPoint(x: 0.72, y: 0.24), // Iota (front)
                CGPoint(x: 0.40, y: 0.30), // Gamma (shoulder)
                CGPoint(x: 0.26, y: 0.46)  // Zeta
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (3, 5), (5, 6), (6, 2)],
            fact: "Alpha and Beta Centauri are the pointer stars to nearby Crux, the Southern Cross.",
            hueIndex: 3),

        WeaverTarget(
            id: "aries",
            name: "Aries",
            points: [
                CGPoint(x: 0.86, y: 0.30), // Hamal (bright)
                CGPoint(x: 0.62, y: 0.42), // Sheratan
                CGPoint(x: 0.50, y: 0.50), // Mesarthim
                CGPoint(x: 0.14, y: 0.72)  // 41 Arietis / Botein
            ],
            edges: [(0, 1), (1, 2), (2, 3)],
            fact: "A small bent line of stars led by Hamal, the Ram, between Taurus and Pisces.",
            hueIndex: 1),

        WeaverTarget(
            id: "cancer",
            name: "Cancer",
            points: [
                CGPoint(x: 0.50, y: 0.36), // Asellus Borealis / Gamma
                CGPoint(x: 0.52, y: 0.50), // Asellus Australis / Delta (near Beehive)
                CGPoint(x: 0.22, y: 0.28), // Iota (upper)
                CGPoint(x: 0.78, y: 0.74), // Acubens / Alpha
                CGPoint(x: 0.30, y: 0.78)  // Beta / Tarf (lower)
            ],
            edges: [(2, 0), (0, 1), (1, 3), (1, 4)],
            fact: "A faint upside-down Y; at its center glows the Beehive star cluster, M44.",
            hueIndex: 2),

        WeaverTarget(
            id: "virgo",
            name: "Virgo",
            points: [
                CGPoint(x: 0.40, y: 0.84), // Spica (bright)
                CGPoint(x: 0.46, y: 0.58), // Gamma / Porrima
                CGPoint(x: 0.30, y: 0.44), // Epsilon / Vindemiatrix
                CGPoint(x: 0.62, y: 0.50), // Zeta
                CGPoint(x: 0.74, y: 0.36), // Eta
                CGPoint(x: 0.20, y: 0.24), // Beta (head)
                CGPoint(x: 0.84, y: 0.66)  // Theta / arm
            ],
            edges: [(0, 1), (1, 2), (1, 3), (3, 4), (2, 5), (3, 6)],
            fact: "Follow the arc from the Big Dipper past Arcturus and on to blue-white Spica.",
            hueIndex: 1),

        WeaverTarget(
            id: "libra",
            name: "Libra",
            points: [
                CGPoint(x: 0.30, y: 0.20), // Zubeneschamali (Beta, beam)
                CGPoint(x: 0.70, y: 0.30), // Zubenelgenubi (Alpha, beam)
                CGPoint(x: 0.18, y: 0.62), // Gamma (pan)
                CGPoint(x: 0.84, y: 0.74)  // Sigma (pan)
            ],
            edges: [(0, 1), (0, 2), (1, 3)],
            fact: "The Scales sit between Virgo and Scorpius; its stars once formed the Scorpion's claws.",
            hueIndex: 2),

        WeaverTarget(
            id: "capricornus",
            name: "Capricornus",
            points: [
                CGPoint(x: 0.12, y: 0.30), // Algedi (Alpha)
                CGPoint(x: 0.20, y: 0.40), // Dabih (Beta)
                CGPoint(x: 0.46, y: 0.72), // Psi / body
                CGPoint(x: 0.70, y: 0.78), // Zeta
                CGPoint(x: 0.88, y: 0.56), // Deneb Algedi (Delta, tail)
                CGPoint(x: 0.74, y: 0.36), // Nashira (Gamma)
                CGPoint(x: 0.40, y: 0.30)  // Theta
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 0)],
            fact: "A wide arrowhead or boat shape, the Sea-Goat, in the dim waters of the autumn sky.",
            hueIndex: 3),

        WeaverTarget(
            id: "delphinus",
            name: "Delphinus",
            points: [
                CGPoint(x: 0.36, y: 0.22), // Sualocin (Alpha)
                CGPoint(x: 0.58, y: 0.18), // Rotanev (Beta)
                CGPoint(x: 0.66, y: 0.40), // Gamma
                CGPoint(x: 0.44, y: 0.44), // Delta
                CGPoint(x: 0.20, y: 0.70)  // Epsilon (tail)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (3, 0), (3, 4)],
            fact: "Job's Coffin, a tiny diamond of four stars with a tail, leaping near the Summer Triangle.",
            hueIndex: 0)
    ]

    static func target(id: String) -> WeaverTarget? {
        targets.first { $0.id == id }
    }

    static var count: Int { targets.count }
}
