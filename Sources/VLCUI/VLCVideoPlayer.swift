import Foundation
import SwiftUI

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

// TODO: More events
// TODO: Provide VLCVideoPlayer.PlaybackInformation.stats as properties
// TODO: Change FontNameSelector.absolute to use UIFont?
// TODO: Documentation
// TODO: Break nested objects into files

public struct VLCVideoPlayer: UIViewControllerRepresentable {

    // MARK: Scope

    // Configuration for VLCMediaPlayer
    public class Configuration {
        public var options: [String: Any] = [:]
        public var autoPlay: Bool = false
        public var defaultSubtitleIndex: TrackIndexSelector = .auto
        public var defaultAudioIndex: TrackIndexSelector = .auto
        public var defaultSubtitleSize: FontSizeSelector = .auto
        public var defaultFontName: FontNameSelector = .auto
        public var playbackChildren: [PlaybackChild] = []
    }

    // Possible events to send to the underlying VLC media player
    public enum Event {
        /// Play the media
        case play

        /// Pause the media
        case pause

        /// Stop the media and will no longer respond to events
        case stop

        /// Jump forward a given amount of seconds
        case jumpForward(Int32)

        /// Jump backward a given amount of seconds
        case jumpBackward(Int32)

        /// Set the subtitle track index
        case setSubtitleTrack(TrackIndexSelector)

        /// Set the audio track index
        case setAudioTrack(TrackIndexSelector)

        /// Set the media playback speed
        case setPlaybackSpeed(Float)

        /// Aspect fill the video depending on the video's content size and the view's bounds
        case aspectFill(Bool)

        /// Set the player ticks
        case setTicks(Int32)

        /// Set the media subtitle size
        ///
        /// **Note**: Due to VLCKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        case setSubtitleSize(FontSizeSelector)

        /// Set the subtitle font
        case setSubtitleFont(FontNameSelector)

        /// Add a playback child
        case addPlaybackChild(PlaybackChild)
    }

    // Wrapper so that VLCKit imports are not necessary
    public enum State: Int {
        case stopped
        case opening
        case buffering
        case ended
        case error
        case playing
        case paused
        case esAdded
    }

    public struct PlaybackInformation {
        public let position: Float
        public let length: Int32
        public let isSeekable: Bool

        public let currentSubtitleTrack: (Int32, String)
        public let currentAudioTrack: (Int32, String)
        public let subtitleTracks: [Int32: String]
        public let audioTracks: [Int32: String]

        public let stats: [AnyHashable: Any]
    }

    public struct PlaybackChild {
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

    public enum TrackIndexSelector {
        /// Let VLC automatically set a track index, if one is available
        case auto

        /// Set a track index
        case absolute(Int32)
    }

    public enum FontSizeSelector {
        /// Let VLC automatically determine a font size
        case auto

        /// Set a font size
        case absolute(Int)
    }

    public enum FontNameSelector {
        /// Use the default system font
        case auto

        /// Set a font given the font name
        case absolute(String)
    }

    // MARK: Implementation

    private let playbackURL: URL
    private var configure: (Configuration) -> Void
    private var delegate: VLCVideoPlayerDelegate

    public func makeUIViewController(context: Context) -> UIVLCVideoPlayerViewController {
        let configuration = VLCVideoPlayer.Configuration()
        configure(configuration)

        return UIVLCVideoPlayerViewController(
            url: playbackURL,
            configuration: configuration,
            delegate: delegate
        )
    }

    public func updateUIViewController(_ uiViewController: UIVLCVideoPlayerViewController, context: Context) {}
}

public extension VLCVideoPlayer {
    init(url: URL) {
        self.playbackURL = url
        self.configure = { _ in }
        self.delegate = DefaultVideoPlayerDelegate()
    }

    func configure(_ configure: @escaping (VLCVideoPlayer.Configuration) -> Void) -> Self {
        var copy = self
        copy.configure = configure
        return copy
    }

    func delegate(_ delegate: VLCVideoPlayerDelegate) -> Self {
        var copy = self
        copy.delegate = delegate
        return copy
    }
}
