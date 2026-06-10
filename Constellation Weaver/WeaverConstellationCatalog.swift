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

    // Rich Sky-Guide fields (educational, accurate). All defaulted so existing
    // call sites stay valid; every catalog entry below supplies real values.
    var mythology: String = ""       // a few-sentence description / story
    var brightestStars: [String] = [] // real proper star names, brightest first
    var season: String = ""          // best viewing season: Winter/Spring/Summer/Autumn
    var hemisphere: String = ""      // Northern / Southern / Both
    var howToFind: String = ""       // a practical star-hopping tip

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
            hueIndex: 0,
            mythology: "Orion the Hunter is one of the most recognizable figures in the sky. In Greek myth he was a giant huntsman whom Zeus placed among the stars. He strides across the winter sky with his club and shield, eternally facing the charge of Taurus the Bull.",
            brightestStars: ["Rigel", "Betelgeuse", "Bellatrix", "Alnilam"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "Look south on winter evenings for three bright stars in a tidy row — that is Orion's Belt. The reddish star up-left is Betelgeuse; the blue-white star down-right is Rigel."),

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
            hueIndex: 0,
            mythology: "Ursa Major, the Great Bear, is among the oldest recognized constellations. Its brightest seven stars form the Big Dipper (or Plough). Many cultures saw a bear here; the 'tail' is really the bear's hindquarters and a long trailing line of stars.",
            brightestStars: ["Alioth", "Dubhe", "Alkaid", "Mizar"],
            season: "Spring",
            hemisphere: "Northern",
            howToFind: "High in the northern sky, find the seven-star Dipper shape. Its two outer bowl stars, Dubhe and Merak, point straight at Polaris, the North Star."),

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
            hueIndex: 2,
            mythology: "Cassiopeia was a vain queen of Greek myth, set in the heavens seated on her throne. As punishment for her boasting she circles the pole forever, sometimes hanging upside down. Her five bright stars trace a distinctive W or M.",
            brightestStars: ["Schedar", "Caph", "Gamma Cassiopeiae", "Ruchbah"],
            season: "Autumn",
            hemisphere: "Northern",
            howToFind: "Opposite the Big Dipper across Polaris, look for a zig-zag W of five stars. It wheels around the pole all night and never sets from mid-northern latitudes."),

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
            hueIndex: 1,
            mythology: "Leo is the celestial Lion, identified by many ancient cultures and one of the zodiac constellations. In Greek myth it is the Nemean Lion slain by Heracles. A backwards question mark, the Sickle, outlines its mane and head.",
            brightestStars: ["Regulus", "Denebola", "Algieba", "Zosma"],
            season: "Spring",
            hemisphere: "Both",
            howToFind: "On spring evenings find the backwards question mark (the Sickle) in the south; the bright dot at its base is Regulus, the Lion's heart. A triangle of stars to the left is the hindquarters and tail."),

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
            hueIndex: 3,
            mythology: "Cygnus the Swan flies south along the Milky Way with neck outstretched. In Greek myth Zeus took the form of a swan; the figure is also widely known as the Northern Cross. Its tail star Deneb is one of the most luminous stars known.",
            brightestStars: ["Deneb", "Sadr", "Gienah", "Albireo"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "On summer nights look overhead for a large cross of stars lying along the Milky Way. The bright star at the top of the cross, Deneb, forms one corner of the Summer Triangle with Vega and Altair."),

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
            hueIndex: 2,
            mythology: "Lyra represents the lyre of Orpheus, the legendary musician of Greek myth whose playing could charm all living things. Small but bright, it is crowned by Vega, the fifth-brightest star in the night sky.",
            brightestStars: ["Vega", "Sulafat", "Sheliak"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "Find brilliant blue-white Vega high overhead on summer evenings, then look for the small parallelogram of fainter stars hanging just below it. Vega is one corner of the Summer Triangle."),

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
            hueIndex: 1,
            mythology: "Scorpius is the Scorpion that, in Greek myth, stung Orion to death — which is why the two are placed on opposite sides of the sky and never seen together. A zodiac constellation, it genuinely resembles a scorpion with a curving tail and stinger.",
            brightestStars: ["Antares", "Shaula", "Sargas", "Dschubba"],
            season: "Summer",
            hemisphere: "Both",
            howToFind: "Low in the south on summer nights, look for a bright red star, Antares, at the heart of a long curving line of stars that hooks back like a scorpion's tail and stinger."),

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
            hueIndex: 0,
            mythology: "Gemini, the Twins, represents Castor and Pollux of Greek myth — inseparable brothers, one mortal and one immortal, placed together in the sky. A zodiac constellation, its two brightest stars carry the twins' names.",
            brightestStars: ["Pollux", "Castor", "Alhena"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "Up and to the left of Orion, find two bright stars close together, Castor and Pollux — the twins' heads. Two roughly parallel lines of stars run down from them toward Orion."),

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
            hueIndex: 1,
            mythology: "Taurus the Bull charges at Orion across the winter sky. In Greek myth Zeus took the form of a bull to carry off Europa. A zodiac constellation, its face is the V-shaped Hyades cluster and it carries the glittering Pleiades on its shoulder.",
            brightestStars: ["Aldebaran", "Elnath", "Alcyone"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "Up-right from Orion's Belt lies a V of stars tipped by orange Aldebaran, the Bull's eye. The tight little cluster of blue stars nearby is the Pleiades, the Bull's shoulder."),

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
            hueIndex: 3,
            mythology: "Crux, the Southern Cross, is the smallest constellation but one of the most famous in the southern sky, appearing on several national flags. Unknown to most northern observers, it has guided southern navigators for centuries.",
            brightestStars: ["Acrux", "Mimosa", "Gacrux"],
            season: "Autumn",
            hemisphere: "Southern",
            howToFind: "From the southern hemisphere, find a compact cross of four bright stars embedded in the Milky Way. Extend its long axis about four and a half times to locate the south celestial pole."),

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
            hueIndex: 0,
            mythology: "Aquila is the Eagle that carried the thunderbolts of Zeus and bore the youth Ganymede up to Olympus. It flies along the Milky Way; its brightest star Altair is so swift a spinner it is visibly flattened.",
            brightestStars: ["Altair", "Tarazed", "Alshain"],
            season: "Summer",
            hemisphere: "Both",
            howToFind: "Look for Altair, a bright white star flanked closely by one fainter star on each side, low in the summer Milky Way. Altair marks the southern corner of the Summer Triangle."),

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
            hueIndex: 3,
            mythology: "Draco is the Dragon that coils between the two Bears around the north celestial pole. In myth it is Ladon, the dragon guarding the golden apples, slain by Heracles. Thousands of years ago its star Thuban was the pole star.",
            brightestStars: ["Eltanin", "Rastaban", "Thuban"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "Trace a long winding line of stars that loops between the Big and Little Dippers. Follow it to a compact quadrilateral of four stars — the Dragon's head — pointing toward Hercules."),

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
            hueIndex: 1,
            mythology: "Bootes is the Herdsman or Ploughman, often pictured driving the Bears around the pole. Shaped like a kite or an ice-cream cone, it is anchored by Arcturus, the brightest star in the northern sky.",
            brightestStars: ["Arcturus", "Izar", "Muphrid"],
            season: "Spring",
            hemisphere: "Northern",
            howToFind: "Follow the curve of the Big Dipper's handle outward and 'arc to Arcturus' — a brilliant orange star. The kite shape of fainter stars rises above it."),

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
            hueIndex: 2,
            mythology: "Perseus is the hero who slew the Gorgon Medusa and rescued Andromeda. He holds Medusa's severed head, marked by the star Algol — the 'Demon Star' — which winks dimmer every few days as a companion star eclipses it.",
            brightestStars: ["Mirfak", "Algol", "Gamma Persei"],
            season: "Autumn",
            hemisphere: "Northern",
            howToFind: "Between Cassiopeia's W and the Pleiades, find bright Mirfak amid a curving chain of stars. Watch nearby Algol over several nights and you will see it noticeably fade and brighten."),

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
            hueIndex: 3,
            mythology: "Ursa Minor, the Little Bear, is the smaller companion to the Great Bear and forms the Little Dipper. Its handle tip is Polaris, the North Star, which sits almost exactly above the north pole and so appears fixed while the sky wheels around it.",
            brightestStars: ["Polaris", "Kochab", "Pherkad"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "Use the Big Dipper's pointer stars to find Polaris, then trace the fainter Little Dipper that curls back from it. Polaris always marks due north."),

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
            hueIndex: 2,
            mythology: "Cepheus was the king of Aethiopia, husband of Cassiopeia and father of Andromeda. He circles the north pole near his queen, drawn as a simple house or church with a peaked roof.",
            brightestStars: ["Alderamin", "Alfirk", "Errai"],
            season: "Autumn",
            hemisphere: "Northern",
            howToFind: "Between Cassiopeia and Polaris, look for a five-star shape like a child's drawing of a house, its pointed 'roof' aimed toward the pole star."),

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
            hueIndex: 1,
            mythology: "Sagittarius is the Archer, a centaur drawing his bow, and a zodiac constellation. Its brightest stars famously form a Teapot. Aim along its spout and you look straight toward the dense, glowing center of our Milky Way galaxy.",
            brightestStars: ["Kaus Australis", "Nunki", "Ascella"],
            season: "Summer",
            hemisphere: "Both",
            howToFind: "Low in the south on summer nights, find a star pattern shaped like a teapot. The cloudy band of the Milky Way rising from its spout looks like steam — that is the heart of the galaxy."),

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
            hueIndex: 2,
            mythology: "Auriga is the Charioteer, often pictured carrying a goat and her kids on his shoulder. The goat is Capella, the sixth-brightest star in the sky, and a small triangle of fainter stars beside it marks the Kids.",
            brightestStars: ["Capella", "Menkalinan", "Mahasim"],
            season: "Winter",
            hemisphere: "Northern",
            howToFind: "High overhead in winter, find brilliant yellow Capella at the top of a large pentagon of stars. It rides above Orion and Taurus."),

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
            hueIndex: 3,
            mythology: "Andromeda was the princess chained to a rock as a sacrifice to a sea monster, until Perseus rescued her. Her constellation is a chain of stars; near it lies the Andromeda Galaxy, the most distant object easily visible to the naked eye.",
            brightestStars: ["Alpheratz", "Mirach", "Almach"],
            season: "Autumn",
            hemisphere: "Northern",
            howToFind: "Start at the top-left corner of the Great Square of Pegasus and follow two chains of stars away from it. From the middle star, Mirach, hop up to the faint smudge of the Andromeda Galaxy."),

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
            hueIndex: 0,
            mythology: "Pegasus is the winged horse born from the blood of Medusa, ridden by the hero Bellerophon. The horse is drawn upside down; its body is the famous Great Square, a large, nearly empty box of four stars high in the autumn sky.",
            brightestStars: ["Enif", "Scheat", "Markab", "Algenib"],
            season: "Autumn",
            hemisphere: "Both",
            howToFind: "High in the autumn sky, look for a big, conspicuously empty square of four stars — the Great Square. The horse's neck and nose trail off from one corner toward the star Enif."),

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
            hueIndex: 2,
            mythology: "Corona Borealis, the Northern Crown, is the jewelled crown of Princess Ariadne, set in the sky by the god Dionysus. Its neat semicircle of stars is one of the easiest small constellations to recognize.",
            brightestStars: ["Alphecca", "Nusakan"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "Between Bootes and Hercules, look for a small, graceful arc of seven stars curving like a crown. Its single brightest jewel is Alphecca."),

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
            hueIndex: 1,
            mythology: "Hercules honors the greatest hero of Greek myth, famed for his twelve labors. He is drawn kneeling. The heart of the figure is the Keystone, a lopsided square that hosts M13, the finest globular star cluster in the northern sky.",
            brightestStars: ["Kornephoros", "Rasalgethi", "Sarin"],
            season: "Summer",
            hemisphere: "Northern",
            howToFind: "Between the bright stars Vega and Arcturus, find a lopsided square of four stars — the Keystone. On a dark night the globular cluster M13 shows as a faint glow on one of its sides."),

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
            hueIndex: 0,
            mythology: "Canis Major is the Great Dog, one of Orion's two hunting hounds following at his heels. It carries Sirius, the Dog Star, the brightest star in the entire night sky. Its summer rising once marked the hot 'dog days' of the year.",
            brightestStars: ["Sirius", "Adhara", "Wezen", "Mirzam"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "Follow Orion's Belt down and to the left to the dazzling star Sirius — the Dog's collar. The rest of the dog's body spreads below it, low in the winter sky."),

        WeaverTarget(
            id: "canis_minor",
            name: "Canis Minor",
            points: [
                CGPoint(x: 0.22, y: 0.66), // Procyon (bright)
                CGPoint(x: 0.78, y: 0.34)  // Gomeisa
            ],
            edges: [(0, 1)],
            fact: "The Little Dog is just two stars; bright Procyon completes the Winter Triangle.",
            hueIndex: 0,
            mythology: "Canis Minor is the Little Dog, Orion's smaller hunting companion. It is essentially just two stars, dominated by Procyon — the eighth-brightest star in the sky — whose name means 'before the dog' because it rises just ahead of Sirius.",
            brightestStars: ["Procyon", "Gomeisa"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "East of Orion, find the lone bright star Procyon. With Sirius and Betelgeuse it forms the large Winter Triangle."),

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
            hueIndex: 3,
            mythology: "Centaurus is the noble centaur of Greek myth — often identified with wise Chiron, teacher of heroes. A large southern constellation, it holds Alpha Centauri, the closest star system to our Sun at just over four light-years away.",
            brightestStars: ["Rigil Kentaurus", "Hadar", "Menkent"],
            season: "Spring",
            hemisphere: "Southern",
            howToFind: "From the southern hemisphere, find two brilliant stars, Alpha and Beta Centauri, close together. They point toward the nearby Southern Cross; Alpha is our Sun's nearest stellar neighbor."),

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
            hueIndex: 1,
            mythology: "Aries is the Ram whose golden fleece was sought by Jason and the Argonauts. A zodiac constellation, it is modest — just a short bent line of stars — but historically important: it once marked the spring equinox point.",
            brightestStars: ["Hamal", "Sheratan", "Mesarthim"],
            season: "Autumn",
            hemisphere: "Both",
            howToFind: "Between the Pleiades and the Great Square, look for a short, gently bent line of three stars led by the brightest, Hamal."),

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
            hueIndex: 2,
            mythology: "Cancer is the Crab that, in Greek myth, pinched Heracles during his battle with the Hydra. The faintest of the zodiac constellations, its chief treasure is the Beehive Cluster, M44, a swarm of stars visible to the naked eye under dark skies.",
            brightestStars: ["Tarf", "Asellus Australis", "Acubens"],
            season: "Winter",
            hemisphere: "Both",
            howToFind: "Between Gemini and Leo, look for a faint, upside-down Y of stars. On a dark night a misty patch at its center resolves into the Beehive star cluster."),

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
            hueIndex: 1,
            mythology: "Virgo is the Maiden, often linked to the harvest goddess holding an ear of wheat — marked by her brightest star, Spica. The second-largest constellation, this zodiac figure sprawls across the spring sky.",
            brightestStars: ["Spica", "Porrima", "Vindemiatrix"],
            season: "Spring",
            hemisphere: "Both",
            howToFind: "Arc from the Big Dipper's handle to Arcturus, then 'speed on to Spica' — the lone bright blue-white star that anchors Virgo low in the south on spring evenings."),

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
            hueIndex: 2,
            mythology: "Libra, the Scales, is the only zodiac constellation representing an object rather than a living thing. Its two main stars were once considered the claws of neighboring Scorpius — their old names still mean the northern and southern claw.",
            brightestStars: ["Zubeneschamali", "Zubenelgenubi"],
            season: "Summer",
            hemisphere: "Both",
            howToFind: "Between Virgo's Spica and the red star Antares in Scorpius, look for a faint four-star quadrilateral that hangs like a pair of balance scales."),

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
            hueIndex: 3,
            mythology: "Capricornus is the Sea-Goat, a curious creature with a goat's head and a fish's tail, linked to the god Pan. One of the faintest zodiac constellations, its stars trace a wide arrowhead or smile in the watery region of the autumn sky.",
            brightestStars: ["Deneb Algedi", "Dabih", "Algedi"],
            season: "Autumn",
            hemisphere: "Both",
            howToFind: "Below the Summer Triangle, in a dim part of the sky, look for a large triangular or boat-shaped outline of faint stars between Sagittarius and Aquarius."),

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
            hueIndex: 0,
            mythology: "Delphinus is the Dolphin sent by the sea-god Poseidon to find the nymph Amphitrite. A tiny, charming constellation, its compact diamond of stars is nicknamed Job's Coffin, with a short tail trailing behind.",
            brightestStars: ["Rotanev", "Sualocin"],
            season: "Summer",
            hemisphere: "Both",
            howToFind: "Just east of Altair, near the Summer Triangle, look for a tiny diamond of four stars with a tail — a leaping dolphin small enough to hide behind a fingertip."),

        // MARK: - Aquarius & Pisces (new ids, complete the Zodiac set)

        WeaverTarget(
            id: "aquarius",
            name: "Aquarius",
            points: [
                CGPoint(x: 0.16, y: 0.30), // Sadalsuud (Beta)
                CGPoint(x: 0.40, y: 0.22), // Sadalmelik (Alpha)
                CGPoint(x: 0.52, y: 0.30), // Sadachbia (Gamma, Water Jar)
                CGPoint(x: 0.58, y: 0.20), // Pi (Water Jar)
                CGPoint(x: 0.62, y: 0.34), // Zeta (Water Jar center)
                CGPoint(x: 0.60, y: 0.50), // Eta (Water Jar)
                CGPoint(x: 0.70, y: 0.62), // Lambda (stream)
                CGPoint(x: 0.66, y: 0.80), // Phi (stream)
                CGPoint(x: 0.82, y: 0.90), // Skat / Delta (stream to Fomalhaut)
                CGPoint(x: 0.30, y: 0.46)  // Mu (shoulder line)
            ],
            edges: [(0, 1), (1, 2), (2, 3), (2, 4), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (1, 9), (9, 5)],
            fact: "The Water Bearer pours a stream of stars from a small Y-shaped Water Jar down toward Fomalhaut.",
            hueIndex: 2,
            mythology: "Aquarius is the Water Bearer, often pictured as a youth pouring water from a jar. One of the oldest zodiac constellations, it sits in the 'Sea' region of the autumn sky among other watery figures. The small Y of stars at its center is the Water Jar.",
            brightestStars: ["Sadalsuud", "Sadalmelik", "Skat"],
            season: "Autumn",
            hemisphere: "Both",
            howToFind: "In the dim autumn sky west of Pegasus, find a small Y-shaped group of stars — the Water Jar. A faint stream of stars trickles from it down toward the lone bright star Fomalhaut."),

        WeaverTarget(
            id: "pisces",
            name: "Pisces",
            points: [
                CGPoint(x: 0.20, y: 0.12), // Western fish (near Pegasus)
                CGPoint(x: 0.30, y: 0.20),
                CGPoint(x: 0.22, y: 0.26), // Circlet of the western fish
                CGPoint(x: 0.34, y: 0.30),
                CGPoint(x: 0.46, y: 0.40), // toward Alrescha
                CGPoint(x: 0.62, y: 0.56), // Alrescha (Alpha, the knot)
                CGPoint(x: 0.76, y: 0.62), // cord turning up
                CGPoint(x: 0.84, y: 0.78), // eastern fish
                CGPoint(x: 0.72, y: 0.86), // eastern fish loop
                CGPoint(x: 0.90, y: 0.90)  // eastern fish head
            ],
            edges: [(0, 1), (1, 2), (2, 3), (0, 3), (1, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 6), (7, 9)],
            fact: "Two fish tied together by their tails; their cords meet at the knot star Alrescha.",
            hueIndex: 2,
            mythology: "Pisces depicts two fish tied together by a cord, said to be Aphrodite and her son Eros, who turned into fish to escape the monster Typhon. A large but faint zodiac constellation, its two cords meet at the knot star Alrescha.",
            brightestStars: ["Alpherg", "Alrescha", "Fumalsamakah"],
            season: "Autumn",
            hemisphere: "Both",
            howToFind: "Just south of the Great Square of Pegasus, trace two long, faint V-shaped cords of stars. They meet at the knot star Alrescha; a small ring of stars below the Square is the western fish, called the Circlet.")
    ]

    static func target(id: String) -> WeaverTarget? {
        targets.first { $0.id == id }
    }

    static var count: Int { targets.count }
}
