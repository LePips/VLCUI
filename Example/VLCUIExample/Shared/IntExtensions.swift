import Foundation

struct RuntimeFormatStyle: FormatStyle {
    
    func format(_ value: Int) -> String {
        guard value >= 0 else {
             return "--:--"
         }

        let minutes = (value / 60).formatted(.number.precision(.integerLength(2)))
        let seconds = (value % 60).formatted(.number.precision(.integerLength(2)))
        return "\(minutes):\(seconds)"
    }
}

extension FormatStyle where Self == RuntimeFormatStyle {
    
    static var runtime: RuntimeFormatStyle {
        RuntimeFormatStyle()
    }
}
