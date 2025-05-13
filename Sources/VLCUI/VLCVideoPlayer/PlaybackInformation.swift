import Foundation

public extension VLCVideoPlayer {

    struct PlaybackInformation {
        public let startConfiguration: VLCVideoPlayer.Configuration
        public let position: Float
        public let length: Int
        public let isSeekable: Bool
        public let playbackRate: Float
        public let videoSize: CGSize

        public let currentSubtitleTrack: MediaTrack
        public let currentAudioTrack: MediaTrack
        public let subtitleTracks: [MediaTrack]
        public let audioTracks: [MediaTrack]

        public let numberOfReadBytesOnInput: Int
        public let inputBitrate: Float
        public let numberOfReadBytesOnDemux: Int
        public let demuxBitrate: Float
        public let numberOfDecodedVideoBlocks: Int
        public let numberOfDecodedAudioBlocks: Int
        public let numberOfDisplayedPictures: Int
        public let numberOfLostPictures: Int
        public let numberOfPlayedAudioBuffers: Int
        public let numberOfLostAudioBuffers: Int
        public let numberOfSentPackets: Int
        public let numberOfSentBytes: Int
        public let streamOutputBitrate: Float
        public let numberOfCorruptedDataPackets: Int
        public let numberOfDiscontinuties: Int
    }
}
