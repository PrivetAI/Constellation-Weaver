import Foundation
import SwiftUI

// Central observable store: persists saved constellations + which skies are
// unlocked. Local JSON file in Application Support — fully offline.
final class WeaverStore: ObservableObject {

    @Published private(set) var constellations: [WeaverConstellation] = []
    @Published private(set) var unlockedSkyCount: Int = 2

    static let maxSkies = 8
    private let fileName = "weaver_atlas.json"

    private struct WeaverSaveBundle: Codable {
        var constellations: [WeaverConstellation]
        var unlockedSkyCount: Int
    }

    init() {
        load()
        if unlockedSkyCount < 2 { unlockedSkyCount = 2 }
        if unlockedSkyCount > Self.maxSkies { unlockedSkyCount = Self.maxSkies }
    }

    // MARK: - Derived

    var totalCount: Int { constellations.count }

    func count(forSky skyId: Int) -> Int {
        constellations.filter { $0.skyId == skyId }.count
    }

    var unlockedSkies: [WeaverSky] {
        (0..<unlockedSkyCount).map { WeaverSkyGenerator.generate(id: $0) }
    }

    // MARK: - Mutations

    func add(_ constellation: WeaverConstellation) {
        constellations.insert(constellation, at: 0)
        save()
    }

    func delete(_ constellation: WeaverConstellation) {
        constellations.removeAll { $0.id == constellation.id }
        save()
    }

    func rename(_ constellation: WeaverConstellation, to newName: String, note: String) {
        guard let idx = constellations.firstIndex(where: { $0.id == constellation.id }) else { return }
        constellations[idx].name = newName
        constellations[idx].note = note
        save()
    }

    func unlockNextSky() {
        guard unlockedSkyCount < Self.maxSkies else { return }
        unlockedSkyCount += 1
        save()
    }

    var canUnlockMore: Bool { unlockedSkyCount < Self.maxSkies }

    // MARK: - Persistence

    private func fileURL() -> URL? {
        let fm = FileManager.default
        guard let dir = try? fm.url(for: .applicationSupportDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true) else { return nil }
        return dir.appendingPathComponent(fileName)
    }

    private func load() {
        guard let url = fileURL(),
              let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let bundle = try? decoder.decode(WeaverSaveBundle.self, from: data) {
            constellations = bundle.constellations.sorted { $0.createdAt > $1.createdAt }
            unlockedSkyCount = bundle.unlockedSkyCount
        }
    }

    private func save() {
        guard let url = fileURL() else { return }
        let bundle = WeaverSaveBundle(constellations: constellations,
                                      unlockedSkyCount: unlockedSkyCount)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        if let data = try? encoder.encode(bundle) {
            try? data.write(to: url, options: [.atomic])
        }
    }
}
