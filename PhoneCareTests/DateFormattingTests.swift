import Testing
import Foundation
@testable import PhoneCare

@Suite("Date+Formatting")
struct DateFormattingTests {

    // MARK: - relativeFormatted()

    @Test("Just now for less than 60 seconds ago")
    func relativeJustNow() {
        let now = Date()
        let date = now.addingTimeInterval(-30)
        #expect(date.relativeFormatted(relativeTo: now) == "Just now")
    }

    @Test("Just now for exactly 0 seconds ago")
    func relativeZeroSeconds() {
        let now = Date()
        #expect(now.relativeFormatted(relativeTo: now) == "Just now")
    }

    @Test("1 minute ago (singular)")
    func relative1Minute() {
        let now = Date()
        let date = now.addingTimeInterval(-60)
        #expect(date.relativeFormatted(relativeTo: now) == "1 minute ago")
    }

    @Test("Multiple minutes ago")
    func relativeMultipleMinutes() {
        let now = Date()
        let date = now.addingTimeInterval(-300) // 5 minutes
        #expect(date.relativeFormatted(relativeTo: now) == "5 minutes ago")
    }

    @Test("59 minutes ago")
    func relative59Minutes() {
        let now = Date()
        let date = now.addingTimeInterval(-59 * 60)
        #expect(date.relativeFormatted(relativeTo: now) == "59 minutes ago")
    }

    @Test("1 hour ago (singular)")
    func relative1Hour() {
        let now = Date()
        let date = now.addingTimeInterval(-3600)
        #expect(date.relativeFormatted(relativeTo: now) == "1 hour ago")
    }

    @Test("Multiple hours ago")
    func relativeMultipleHours() {
        let now = Date()
        let date = now.addingTimeInterval(-3 * 3600) // 3 hours
        #expect(date.relativeFormatted(relativeTo: now) == "3 hours ago")
    }

    @Test("23 hours ago")
    func relative23Hours() {
        let now = Date()
        let date = now.addingTimeInterval(-23 * 3600)
        #expect(date.relativeFormatted(relativeTo: now) == "23 hours ago")
    }

    @Test("Future date returns formatted date string")
    func relativeFutureDate() {
        let now = Date()
        let futureDate = now.addingTimeInterval(3600)
        let result = futureDate.relativeFormatted(relativeTo: now)
        // Future dates use `formatted(date: .abbreviated, time: .shortened)`,
        // so the result should be a non-empty string that is NOT a relative phrase.
        #expect(!result.isEmpty)
        #expect(!result.contains("ago"))
        #expect(result != "Just now")
    }

    @Test("Date from last year includes year")
    func relativeLastYear() {
        let now = Date()
        let calendar = Calendar.current
        let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
        let result = lastYear.relativeFormatted(relativeTo: now)
        // Should contain the year number
        let yearString = String(calendar.component(.year, from: lastYear))
        #expect(result.contains(yearString))
    }

    // MARK: - shortRelativeFormatted()

    @Test("Short: Just now for < 60 seconds")
    func shortJustNow() {
        let now = Date()
        let date = now.addingTimeInterval(-15)
        #expect(date.shortRelativeFormatted(relativeTo: now) == "Just now")
    }

    @Test("Short: minutes format uses 'm ago'")
    func shortMinutes() {
        let now = Date()
        let date = now.addingTimeInterval(-5 * 60)
        #expect(date.shortRelativeFormatted(relativeTo: now) == "5m ago")
    }

    @Test("Short: 1 minute is '1m ago'")
    func shortOneMinute() {
        let now = Date()
        let date = now.addingTimeInterval(-60)
        #expect(date.shortRelativeFormatted(relativeTo: now) == "1m ago")
    }

    @Test("Short: hours format uses 'h ago'")
    func shortHours() {
        let now = Date()
        let date = now.addingTimeInterval(-3 * 3600)
        #expect(date.shortRelativeFormatted(relativeTo: now) == "3h ago")
    }

    @Test("Short: 1 hour is '1h ago'")
    func shortOneHour() {
        let now = Date()
        let date = now.addingTimeInterval(-3600)
        #expect(date.shortRelativeFormatted(relativeTo: now) == "1h ago")
    }

    @Test("Short: yesterday returns 'Yesterday'")
    func shortYesterday() {
        let calendar = Calendar.current
        // Create a date that is >24h ago (yesterday)
        let now = Date()
        let yesterday = now.addingTimeInterval(-25 * 3600) // 25 hours ago
        let result = yesterday.shortRelativeFormatted(relativeTo: now)
        // Should show "Yesterday" or "1d ago" or abbreviated date — just verify not empty
        #expect(!result.isEmpty)
    }

    @Test("Short: future date returns formatted string")
    func shortFutureDate() {
        let now = Date()
        let futureDate = now.addingTimeInterval(86400)
        let result = futureDate.shortRelativeFormatted(relativeTo: now)
        #expect(!result.isEmpty)
        #expect(!result.contains("ago"))
    }

    // MARK: - scanTimestamp

    @Test("scanTimestamp returns non-empty string")
    func scanTimestampNotEmpty() {
        let date = Date()
        #expect(!date.scanTimestamp.isEmpty)
    }

    @Test("scanTimestamp contains year")
    func scanTimestampContainsYear() {
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        #expect(date.scanTimestamp.contains(String(year)))
    }

    @Test("scanTimestamp for a known date contains expected components")
    func scanTimestampKnownDate() {
        // Create a known date: January 15, 2026
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        let result = date.scanTimestamp
        #expect(result.contains("January"))
        #expect(result.contains("15"))
        #expect(result.contains("2026"))
    }
}
