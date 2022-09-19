import Foundation

public extension VLCVideoPlayer {

    enum ValueSelector<ValueType> {
        /// Automatically determine a value
        case auto

        /// Set given an absolute value
        case absolute(ValueType)
    }

    enum TimeSelector {
        /// Set the time in ticks
        case ticks(Int32)

        /// Set the time in seconds
        case seconds(Int32)

        var asTicks: Int32 {
            switch self {
            case let .ticks(ticks):
                return ticks
            case let .seconds(seconds):
                return seconds * 1000
            }
        }
    }
}
