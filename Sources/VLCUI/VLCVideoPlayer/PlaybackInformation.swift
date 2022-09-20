import Foundation

public extension VLCVideoPlayer {

    struct PlaybackInformation {
        public let currentConfiguration: VLCVideoPlayer.Configuration
        public let position: Float
        public let length: Int32
        public let isSeekable: Bool
        public let playbackRate: Float

        public let currentSubtitleTrack: (Int32, String)
        public let currentAudioTrack: (Int32, String)
        public let subtitleTracks: [Int32: String]
        public let audioTracks: [Int32: String]

        public let stats: [AnyHashable: Any]
    }
}
