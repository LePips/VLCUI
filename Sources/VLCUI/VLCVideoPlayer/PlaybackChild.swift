#if os(macOS)
import VLCKit
#elseif os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

public extension VLCVideoPlayer {

    struct PlaybackChild {
        public let url: URL
        public let type: PlaybackChildType
        public let enforce: Bool

        public init(url: URL, type: PlaybackChildType, enforce: Bool) {
            self.url = url
            self.type = type
            self.enforce = enforce
        }

        // Wrapper so that VLCKit imports are not necessary
        public enum PlaybackChildType {
            case subtitle
            case audio

            var asVLCSlaveType: VLCMediaPlaybackSlaveType {
                switch self {
                case .subtitle: return .subtitle
                case .audio: return .audio
                }
            }
        }
    }
}
