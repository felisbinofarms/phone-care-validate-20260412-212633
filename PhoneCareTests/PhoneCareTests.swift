import Testing
@testable import PhoneCare

@Suite("PhoneCare Sanity Checks")
struct PhoneCareTests {

    @Test("Module imports successfully")
    func moduleImports() {
        // If this compiles and runs, the PhoneCare module is accessible.
        #expect(true)
    }

    @Test("Health score calculator is available")
    func calculatorAvailable() {
        let input = HealthScoreInput(
            totalStorageBytes: 100,
            usedStorageBytes: 50,
            totalPhotos: 0,
            duplicatePhotos: 0,
            totalContacts: 0,
            duplicateContacts: 0,
            batteryHealth: 1.0,
            batteryLevel: 1.0,
            totalPermissions: 0,
            appropriatelySetPermissions: 0
        )
        let result = HealthScoreCalculator.calculate(from: input)
        #expect(result.compositeScore >= 0)
        #expect(result.compositeScore <= 100)
    }
}
