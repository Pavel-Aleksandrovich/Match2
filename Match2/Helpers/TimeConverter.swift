import Foundation

enum TimeConverter {
    static func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
}
