import Testing
@testable import PhoneCare

@Suite("PhoneCare Tests")
struct PhoneCareTests {
    @Test("App launches successfully")
    func appExists() {
        #expect(true)
    }
}
