import Foundation

// A themed Collection / Set of catalog constellations. Membership is by stable
// catalog id, so a constellation can belong to several sets at once. Progress
// and completion are DERIVED at runtime from the store's discovered ids — sets
// add no new persistence.
struct WeaverSet: Identifiable, Equatable {
    let id: String            // stable set id
    let name: String          // display name
    let subtitle: String      // one-line description of the theme
    let accentHue: Int        // theme accent (WeaverTheme.accent index)
    let memberIds: [String]   // catalog ids belonging to this set

    static func == (lhs: WeaverSet, rhs: WeaverSet) -> Bool { lhs.id == rhs.id }

    // Members that actually exist in the catalog, in catalog order, deduped.
    var members: [WeaverTarget] {
        memberIds.compactMap { WeaverConstellationCatalog.target(id: $0) }
    }
}

enum WeaverSets {

    // Ordered list of sets shown as sections in the Trace tab. A constellation
    // may legitimately appear in more than one set (e.g. seasonal + zodiac).
    static let all: [WeaverSet] = [

        WeaverSet(
            id: "zodiac",
            name: "The Zodiac",
            subtitle: "The twelve constellations of the ecliptic",
            accentHue: 1,
            memberIds: [
                "aries", "taurus", "gemini", "cancer", "leo", "virgo",
                "libra", "scorpius", "sagittarius", "capricornus",
                "aquarius", "pisces"
            ]),

        WeaverSet(
            id: "circumpolar",
            name: "Northern Circumpolar",
            subtitle: "Stars that circle the pole and never set",
            accentHue: 3,
            memberIds: [
                "ursa_major", "ursa_minor", "cassiopeia", "cepheus", "draco"
            ]),

        WeaverSet(
            id: "winter",
            name: "Winter Skies",
            subtitle: "The brilliant constellations of frosty nights",
            accentHue: 0,
            memberIds: [
                "orion", "taurus", "gemini", "auriga",
                "canis_major", "canis_minor", "cancer"
            ]),

        WeaverSet(
            id: "spring",
            name: "Spring Skies",
            subtitle: "Risen high as the nights grow milder",
            accentHue: 3,
            memberIds: [
                "leo", "virgo", "bootes", "ursa_major", "centaurus"
            ]),

        WeaverSet(
            id: "summer",
            name: "Summer Skies",
            subtitle: "The Milky Way and the Summer Triangle",
            accentHue: 2,
            memberIds: [
                "cygnus", "lyra", "aquila", "scorpius", "sagittarius",
                "hercules", "corona_borealis", "draco", "delphinus"
            ]),

        WeaverSet(
            id: "autumn",
            name: "Autumn Skies",
            subtitle: "The watery realm and the royal family",
            accentHue: 1,
            memberIds: [
                "pegasus", "andromeda", "perseus", "cassiopeia", "cepheus",
                "aquarius", "pisces", "aries", "capricornus"
            ]),

        WeaverSet(
            id: "southern",
            name: "Southern Cross",
            subtitle: "Jewels of the far southern sky",
            accentHue: 3,
            memberIds: [
                "crux", "centaurus"
            ])
    ]

    static func set(id: String) -> WeaverSet? {
        all.first { $0.id == id }
    }

    // All sets a given constellation belongs to, in display order.
    static func sets(containing targetId: String) -> [WeaverSet] {
        all.filter { $0.memberIds.contains(targetId) }
    }
}
