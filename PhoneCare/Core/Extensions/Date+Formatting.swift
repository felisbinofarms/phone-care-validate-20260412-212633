import Foundation

// MARK: - User-Friendly Date Formatting

extension Date {

    /// Returns a human-readable relative string for scan timestamps.
    ///
    /// Examples:
    /// - "Just now"          (< 60 seconds ago)
    /// - "2 minutes ago"     (< 60 minutes ago)
    /// - "1 hour ago"        (< 2 hours ago)
    /// - "3 hours ago"       (2-23 hours ago)
    /// - "Today at 2:30 PM"  (today, >= 24 hours is not possible, but handles edge)
    /// - "Yesterday at 9:15 AM"
    /// - "March 15"          (this year, older than yesterday)
    /// - "March 15, 2025"    (prior year)
    func relativeFormatted(relativeTo now: Date = .now) -> String {
        let seconds = now.timeIntervalSince(self)

        // Future dates
        guard seconds >= 0 else {
            return formatted(date: .abbreviated, time: .shortened)
        }

        // Less than 60 seconds
        if seconds < 60 {
            return "Just now"
        }

        // Less than 60 minutes
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }

        // Less than 24 hours
        let hours = Int(seconds / 3600)
        if hours < 24 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        }

        // Check if yesterday
        let calendar = Calendar.current
        if calendar.isDateInYesterday(self) {
            let timeString = formatted(date: .omitted, time: .shortened)
            return "Yesterday at \(timeString)"
        }

        // Check if today (edge case: exactly 24 hours ago might still be today)
        if calendar.isDateInToday(self) {
            let timeString = formatted(date: .omitted, time: .shortened)
            return "Today at \(timeString)"
        }

        // Same year
        if calendar.component(.year, from: self) == calendar.component(.year, from: now) {
            return formatted(.dateTime.month(.wide).day())
        }

        // Different year
        return formatted(.dateTime.month(.wide).day().year())
    }

    /// Short relative string for compact UI (e.g. list subtitles).
    ///
    /// Examples: "Just now", "5m ago", "3h ago", "Yesterday", "Mar 15"
    func shortRelativeFormatted(relativeTo now: Date = .now) -> String {
        let seconds = now.timeIntervalSince(self)

        guard seconds >= 0 else {
            return formatted(date: .abbreviated, time: .omitted)
        }

        if seconds < 60 {
            return "Just now"
        }

        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes)m ago"
        }

        let hours = Int(seconds / 3600)
        if hours < 24 {
            return "\(hours)h ago"
        }

        let calendar = Calendar.current
        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }

        if calendar.component(.year, from: self) == calendar.component(.year, from: now) {
            return formatted(.dateTime.month(.abbreviated).day())
        }

        return formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// Formatted scan timestamp for detail views.
    ///
    /// Example: "March 15, 2026 at 2:30 PM"
    var scanTimestamp: String {
        formatted(.dateTime.month(.wide).day().year().hour().minute())
    }
}
