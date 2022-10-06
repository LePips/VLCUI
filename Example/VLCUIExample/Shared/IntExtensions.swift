import Foundation

extension Int32 {

    var timeLabel: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: TimeInterval(Int(self))) ?? "--:--"
    }
}
