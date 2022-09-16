import Foundation
import SwiftUI

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

// TODO: More events

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

        /// Stop the media. Will no longer response to `.play` or `.pause` events
        case stop

        /// Jump forward a given amount of seconds
        case jumpForward(Int32)

        /// Jump backward a given amount of seconds
        case jumpBackward(Int32)

        /// Set the subtitle track index
        case setSubtitleIndex(TrackIndexSelector)

        /// Set the audio track index
        case setAudioIndex(TrackIndexSelector)

        /// Set the media playback speed
        case setPlaybackSpeed(Float)

        /// Aspect fill the video depending on the video's content size and the view's bounds
        case aspectFill(Bool)

        /// Set the unit position
        ///
        /// **Note:** position is unstable and may not indicate an accurate position
        case setPosition(Float)

        /// Set the media subtitle size
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
        /// Let VLC automatically determine a track index
        case auto

        /// Set an absolute track index
        case absolute(Int32)
    }

    public enum FontSizeSelector {
        /// Let VLC automatically determine a font size
        case auto

        /// Set an absolute font size
        case absolute(Int)
    }

    public enum FontNameSelector {
        /// Let VLC automatically determine a font
        case auto

        /// Set an absolute font
        case absolute(String)
    }

    // MARK: Implementation

    private let playbackURL: URL
    private var configure: (Configuration) -> Void
    private var delegate: VLCVideoPlayerDelegate?

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
        self.delegate = nil
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
