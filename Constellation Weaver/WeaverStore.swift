import Foundation
import SwiftUI

// Central observable store: persists saved constellations + which skies are
// unlocked, plus discovered trace targets, onboarding state and achievements.
// Local JSON file in Application Support — fully offline.
final class WeaverStore: ObservableObject {

    @Published private(set) var constellations: [WeaverConstellation] = []
    @Published private(set) var unlockedSkyCount: Int = 2
    @Published private(set) var discoveredConstellationIds: Set<String> = []
    @Published private(set) var unlockedAchievements: Set<String> = []
    @Published var onboardingDone: Bool = false

    // Daily return streak. lastDailyDay is the en_US_POSIX yyyy-MM-dd string of
    // the most recent day the user opened the daily; dailyStreak is the current
    // consecutive-day run, bestDailyStreak the record. Additive + backward-safe.
    @Published private(set) var lastDailyDay: String = ""
    @Published private(set) var dailyStreak: Int = 0
    @Published private(set) var bestDailyStreak: Int = 0

    // The most recently unlocked achievement, for a transient toast. Not persisted.
    @Published var recentAchievement: WeaverAchievement? = nil

    static let maxSkies = 12
    private let fileName = "weaver_atlas.json"

    // Backward-compatible bundle: new fields are optional on decode so existing
    // saves (which lack them) load without loss.
    private struct WeaverSaveBundle: Codable {
        var constellations: [WeaverConstellation]
        var unlockedSkyCount: Int
        var discoveredConstellationIds: [String]?
        var unlockedAchievements: [String]?
        var onboardingDone: Bool?
        var lastDailyDay: String?
        var dailyStreak: Int?
        var bestDailyStreak: Int?
    }

    init() {
        load()
        if unlockedSkyCount < 2 { unlockedSkyCount = 2 }
        if unlockedSkyCount > Self.maxSkies { unlockedSkyCount = Self.maxSkies }
        // Re-evaluate achievements once on launch (no toast on this pass).
        evaluateAchievements(announce: false)
    }

    // MARK: - Derived

    var totalCount: Int { constellations.count }

    func count(forSky skyId: Int) -> Int {
        constellations.filter { $0.skyId == skyId }.count
    }

    var unlockedSkies: [WeaverSky] {
        (0..<unlockedSkyCount).map { WeaverSkyGenerator.generate(id: $0) }
    }

    var discoveredCount: Int { discoveredConstellationIds.count }

    func isDiscovered(_ targetId: String) -> Bool {
        discoveredConstellationIds.contains(targetId)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        unlockedAchievements.contains(id)
    }

    var progressSnapshot: WeaverProgressSnapshot {
        WeaverProgressSnapshot(
            savedFigures: constellations.count,
            discoveredConstellations: discoveredConstellationIds.count,
            totalConstellations: WeaverConstellationCatalog.count,
            skiesRevealed: unlockedSkyCount)
    }

    // MARK: - Mutations

    func add(_ constellation: WeaverConstellation) {
        constellations.insert(constellation, at: 0)
        save()
        evaluateAchievements(announce: true)
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
        evaluateAchievements(announce: true)
    }

    var canUnlockMore: Bool { unlockedSkyCount < Self.maxSkies }

    func markDiscovered(_ targetId: String) {
        guard !discoveredConstellationIds.contains(targetId) else { return }
        discoveredConstellationIds.insert(targetId)
        save()
        evaluateAchievements(announce: true)
    }

    func completeOnboarding() {
        guard !onboardingDone else { return }
        onboardingDone = true
        save()
    }

    func replayOnboarding() {
        onboardingDone = false
        save()
    }

    // MARK: - Achievements

    private func evaluateAchievements(announce: Bool) {
        let snap = progressSnapshot
        var newlyUnlocked: [WeaverAchievement] = []
        for a in WeaverAchievementsCatalog.all where !unlockedAchievements.contains(a.id) {
            if a.isEarned(snap) {
                unlockedAchievements.insert(a.id)
                newlyUnlocked.append(a)
            }
        }
        guard !newlyUnlocked.isEmpty else { return }
        save()
        if announce, let first = newlyUnlocked.first {
            recentAchievement = first
        }
    }

    // MARK: - Constellation of the Day + return streak

    // A shared, stable formatter: en_US_POSIX yyyy-MM-dd, current calendar/zone.
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dayKey(for date: Date) -> String { dayFormatter.string(from: date) }

    // Deterministic pick of the day's constellation from its date string.
    func dailyTarget(for date: Date = Date()) -> WeaverTarget {
        let targets = WeaverConstellationCatalog.targets
        guard !targets.isEmpty else {
            // Should never happen; catalog is non-empty.
            return WeaverConstellationCatalog.targets.first!
        }
        let key = Self.dayKey(for: date)
        // Stable FNV-1a style hash over the date string → index.
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        let index = Int(hash % UInt64(targets.count))
        return targets[index]
    }

    // Days that count as "yesterday" relative to today's key, to detect a streak
    // continuation vs a reset. Uses the gregorian calendar.
    private func dayKey(offsetDays: Int, from date: Date) -> String? {
        let cal = Calendar(identifier: .gregorian)
        guard let d = cal.date(byAdding: .day, value: offsetDays, to: date) else { return nil }
        return Self.dayKey(for: d)
    }

    // Call when the user opens / views the daily. Increments the streak once per
    // calendar day; a missed day (gap) resets the streak to 1.
    func registerDailyVisit(date: Date = Date()) {
        let today = Self.dayKey(for: date)
        if lastDailyDay == today { return } // already counted today

        let yesterday = dayKey(offsetDays: -1, from: date)
        if lastDailyDay.isEmpty {
            dailyStreak = 1
        } else if lastDailyDay == yesterday {
            dailyStreak += 1            // consecutive day
        } else {
            dailyStreak = 1            // gap → reset
        }
        lastDailyDay = today
        if dailyStreak > bestDailyStreak { bestDailyStreak = dailyStreak }
        save()
    }

    // True once the user has opened today's daily (so the card can reflect it).
    func hasVisitedToday(date: Date = Date()) -> Bool {
        lastDailyDay == Self.dayKey(for: date)
    }

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
            discoveredConstellationIds = Set(bundle.discoveredConstellationIds ?? [])
            unlockedAchievements = Set(bundle.unlockedAchievements ?? [])
            onboardingDone = bundle.onboardingDone ?? false
            lastDailyDay = bundle.lastDailyDay ?? ""
            dailyStreak = bundle.dailyStreak ?? 0
            bestDailyStreak = bundle.bestDailyStreak ?? 0
        }
    }

    private func save() {
        guard let url = fileURL() else { return }
        let bundle = WeaverSaveBundle(
            constellations: constellations,
            unlockedSkyCount: unlockedSkyCount,
            discoveredConstellationIds: Array(discoveredConstellationIds),
            unlockedAchievements: Array(unlockedAchievements),
            onboardingDone: onboardingDone,
            lastDailyDay: lastDailyDay,
            dailyStreak: dailyStreak,
            bestDailyStreak: bestDailyStreak)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        if let data = try? encoder.encode(bundle) {
            try? data.write(to: url, options: [.atomic])
        }
    }
}
