import Foundation

public extension VLCVideoPlayer {

    enum LoggingLevel: Int {
        case info
        case error
        case warning
        case debug

        public init?(rawValue: Int) {
            switch rawValue {
            case 0:
                self = .info
            case 1:
                self = .error
            case 2:
                self = .warning
            case 3, 4:
                self = .debug
            default:
                return nil
            }
        }
    }
}
