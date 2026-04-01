import Testing
@testable import PhoneCare

@Suite("HealthScoreCalculator")
struct HealthScoreCalculatorTests {

    // MARK: - Composite Score

    @Test("All zero/worst inputs produce score 0")
    func allZeroInputsScoreZero() {
        let input = HealthScoreInput(
            totalStorageBytes: 100,
            usedStorageBytes: 100,          // 0% free -> storage 0
            totalPhotos: 10,
            duplicatePhotos: 10,            // 100% dupes -> photos 0
            totalContacts: 10,
            duplicateContacts: 10,          // 100% dupes -> contacts 0
            batteryHealth: 0.0,             // 0% health -> battery 0
            batteryLevel: 0.0,
            totalPermissions: 10,
            appropriatelySetPermissions: 0  // 0% appropriate -> privacy 0
        )
        let result = HealthScoreCalculator.calculate(from: input)
        #expect(result.compositeScore == 0)
    }

    @Test("All perfect inputs produce score 100")
    func allPerfectInputsScore100() {
        let input = HealthScoreInput(
            totalStorageBytes: 100,
            usedStorageBytes: 0,            // 100% free -> storage 100
            totalPhotos: 100,
            duplicatePhotos: 0,             // no dupes -> photos 100
            totalContacts: 50,
            duplicateContacts: 0,           // no dupes -> contacts 100
            batteryHealth: 1.0,             // 100% health -> battery 100
            batteryLevel: 1.0,
            totalPermissions: 10,
            appropriatelySetPermissions: 10 // 100% appropriate -> privacy 100
        )
        let result = HealthScoreCalculator.calculate(from: input)
        #expect(result.compositeScore == 100)
    }

    @Test("Result includes per-domain breakdown with all five domains")
    func breakdownContainsAllDomains() {
        let input = HealthScoreInput(
            totalStorageBytes: 100,
            usedStorageBytes: 50,
            totalPhotos: 10,
            duplicatePhotos: 5,
            totalContacts: 10,
            duplicateContacts: 5,
            batteryHealth: 0.5,
            batteryLevel: 0.5,
            totalPermissions: 10,
            appropriatelySetPermissions: 5
        )
        let result = HealthScoreCalculator.calculate(from: input)

        #expect(result.breakdown.count == 5)
        let domainNames = Set(result.breakdown.map(\.domain))
        #expect(domainNames.contains("storage"))
        #expect(domainNames.contains("photos"))
        #expect(domainNames.contains("contacts"))
        #expect(domainNames.contains("battery"))
        #expect(domainNames.contains("privacy"))
    }

    // MARK: - Weight Distribution

    @Test("Storage weight is 0.40")
    func storageWeight() {
        let result = makeResult()
        let storageDomain = result.breakdown.first(where: { $0.domain == "storage" })!
        #expect(storageDomain.weight == 0.40)
    }

    @Test("Photos weight is 0.20")
    func photosWeight() {
        let result = makeResult()
        let domain = result.breakdown.first(where: { $0.domain == "photos" })!
        #expect(domain.weight == 0.20)
    }

    @Test("Contacts weight is 0.10")
    func contactsWeight() {
        let result = makeResult()
        let domain = result.breakdown.first(where: { $0.domain == "contacts" })!
        #expect(domain.weight == 0.10)
    }

    @Test("Battery weight is 0.20")
    func batteryWeight() {
        let result = makeResult()
        let domain = result.breakdown.first(where: { $0.domain == "battery" })!
        #expect(domain.weight == 0.20)
    }

    @Test("Privacy weight is 0.10")
    func privacyWeight() {
        let result = makeResult()
        let domain = result.breakdown.first(where: { $0.domain == "privacy" })!
        #expect(domain.weight == 0.10)
    }

    @Test("Weighted scores sum to composite score")
    func weightedScoresSumToComposite() {
        let input = HealthScoreInput(
            totalStorageBytes: 1000,
            usedStorageBytes: 600,
            totalPhotos: 100,
            duplicatePhotos: 30,
            totalContacts: 50,
            duplicateContacts: 10,
            batteryHealth: 0.85,
            batteryLevel: 0.9,
            totalPermissions: 8,
            appropriatelySetPermissions: 6
        )
        let result = HealthScoreCalculator.calculate(from: input)
        let sum = result.breakdown.reduce(0.0) { $0 + $1.weightedScore }
        let expected = max(0, min(100, Int(sum.rounded())))
        #expect(result.compositeScore == expected)
    }

    // MARK: - Storage Sub-Score

    @Test("Storage: 100% free = score 100")
    func storageFull100Free() {
        #expect(HealthScoreCalculator.storageScore(total: 1000, used: 0) == 100)
    }

    @Test("Storage: 50% free = score 100")
    func storage50Free() {
        #expect(HealthScoreCalculator.storageScore(total: 1000, used: 500) == 100)
    }

    @Test("Storage: 25% free = score 50")
    func storage25Free() {
        #expect(HealthScoreCalculator.storageScore(total: 1000, used: 750) == 50)
    }

    @Test("Storage: 0% free = score 0")
    func storageZeroFree() {
        #expect(HealthScoreCalculator.storageScore(total: 1000, used: 1000) == 0)
    }

    @Test("Storage: total 0 returns 100 (guard)")
    func storageTotalZero() {
        #expect(HealthScoreCalculator.storageScore(total: 0, used: 0) == 100)
    }

    // MARK: - Photo Sub-Score

    @Test("Photos: no duplicates = score 100")
    func photoNoDuplicates() {
        #expect(HealthScoreCalculator.photoScore(total: 100, duplicates: 0) == 100)
    }

    @Test("Photos: no photos at all = score 100")
    func photoNoPhotos() {
        #expect(HealthScoreCalculator.photoScore(total: 0, duplicates: 0) == 100)
    }

    @Test("Photos: 50% duplicates = score 50")
    func photoHalfDuplicates() {
        #expect(HealthScoreCalculator.photoScore(total: 100, duplicates: 50) == 50)
    }

    @Test("Photos: all duplicates = score 0")
    func photoAllDuplicates() {
        #expect(HealthScoreCalculator.photoScore(total: 100, duplicates: 100) == 0)
    }

    @Test("Photos: duplicates capped at total")
    func photoDuplicatesCapped() {
        // Even if duplicates > total, ratio is capped to 1.0
        let score = HealthScoreCalculator.photoScore(total: 50, duplicates: 100)
        #expect(score == 0)
    }

    // MARK: - Contact Sub-Score

    @Test("Contacts: no duplicates = score 100")
    func contactNoDuplicates() {
        #expect(HealthScoreCalculator.contactScore(total: 50, duplicates: 0) == 100)
    }

    @Test("Contacts: all duplicates = score 0")
    func contactAllDuplicates() {
        #expect(HealthScoreCalculator.contactScore(total: 50, duplicates: 50) == 0)
    }

    @Test("Contacts: zero total = score 100")
    func contactZeroTotal() {
        #expect(HealthScoreCalculator.contactScore(total: 0, duplicates: 0) == 100)
    }

    // MARK: - Battery Sub-Score

    @Test("Battery: full health = score 100")
    func batteryFullHealth() {
        #expect(HealthScoreCalculator.batteryScore(health: 1.0, level: 0.5) == 100)
    }

    @Test("Battery: nil health falls back to level")
    func batteryNilHealthFallback() {
        #expect(HealthScoreCalculator.batteryScore(health: nil, level: 0.75) == 75)
    }

    @Test("Battery: zero health = score 0")
    func batteryZeroHealth() {
        #expect(HealthScoreCalculator.batteryScore(health: 0.0, level: 0.5) == 0)
    }

    @Test("Battery: 80% health = score 80")
    func battery80() {
        #expect(HealthScoreCalculator.batteryScore(health: 0.80, level: 0.5) == 80)
    }

    // MARK: - Privacy Sub-Score

    @Test("Privacy: all appropriate = score 100")
    func privacyAllAppropriate() {
        #expect(HealthScoreCalculator.privacyScore(total: 10, appropriate: 10) == 100)
    }

    @Test("Privacy: none appropriate = score 0")
    func privacyNoneAppropriate() {
        #expect(HealthScoreCalculator.privacyScore(total: 10, appropriate: 0) == 0)
    }

    @Test("Privacy: zero total = score 100")
    func privacyZeroTotal() {
        #expect(HealthScoreCalculator.privacyScore(total: 0, appropriate: 0) == 100)
    }

    @Test("Privacy: appropriate capped at total")
    func privacyAppropriateCapped() {
        #expect(HealthScoreCalculator.privacyScore(total: 5, appropriate: 10) == 100)
    }

    // MARK: - Edge Cases

    @Test("Composite score is clamped between 0 and 100")
    func compositeScoreClamped() {
        // Even with extreme inputs the score stays in range
        let input = HealthScoreInput(
            totalStorageBytes: 1,
            usedStorageBytes: 10000,  // more used than total
            totalPhotos: 1,
            duplicatePhotos: 1000,
            totalContacts: 1,
            duplicateContacts: 1000,
            batteryHealth: -1.0,      // negative
            batteryLevel: -1.0,
            totalPermissions: 1,
            appropriatelySetPermissions: -5
        )
        let result = HealthScoreCalculator.calculate(from: input)
        #expect(result.compositeScore >= 0)
        #expect(result.compositeScore <= 100)
    }

    @Test("Per-domain scores via convenience accessors")
    func domainAccessors() {
        let input = HealthScoreInput(
            totalStorageBytes: 1000,
            usedStorageBytes: 750,      // 25% free -> storage 50
            totalPhotos: 100,
            duplicatePhotos: 0,         // photos 100
            totalContacts: 10,
            duplicateContacts: 5,       // contacts 50
            batteryHealth: 0.90,        // battery 90
            batteryLevel: 0.5,
            totalPermissions: 10,
            appropriatelySetPermissions: 8  // privacy 80
        )
        let result = HealthScoreCalculator.calculate(from: input)
        #expect(result.storageScore == 50)
        #expect(result.photoScore == 100)
        #expect(result.contactScore == 50)
        #expect(result.batteryScore == 90)
        #expect(result.privacyScore == 80)
    }

    // MARK: - Helpers

    private func makeResult() -> HealthScoreResult {
        let input = HealthScoreInput(
            totalStorageBytes: 100,
            usedStorageBytes: 50,
            totalPhotos: 10,
            duplicatePhotos: 0,
            totalContacts: 10,
            duplicateContacts: 0,
            batteryHealth: 1.0,
            batteryLevel: 1.0,
            totalPermissions: 5,
            appropriatelySetPermissions: 5
        )
        return HealthScoreCalculator.calculate(from: input)
    }
}
