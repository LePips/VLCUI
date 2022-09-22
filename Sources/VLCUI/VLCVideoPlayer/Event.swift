import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension VLCVideoPlayer {

    // Possible events to send to the underlying VLC media player
    enum Event {
        /// Play the current media
        case play

        /// Pause the current media
        case pause

        /// Stop the current media
        case stop

        /// Stop the current media and stop responding to future events
        case cancel

        /// Jump forward a given amount of seconds
        case jumpForward(Int32)

        /// Jump backward a given amount of seconds
        case jumpBackward(Int32)

        /// Go to the next frame
        ///
        /// **Note**: media will be paused
        case gotoNextFrame

        /// Set the subtitle track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        case setSubtitleTrack(ValueSelector<Int32>)

        /// Set the audio track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        case setAudioTrack(ValueSelector<Int32>)

        /// Set the subtitle delay
        case setSubtitleDelay(TimeSelector)

        /// Set the audio delay
        case setAudioDelay(TimeSelector)

        /// Fast forward at a given rate
        case fastForward(ValueSelector<Float>)

        /// Aspect fill depending on the video's content size and the view's bounds, based
        /// on the given percentage of completion
        ///
        /// **Note**: Does not work on macOS
        case aspectFill(Float)

        /// Set the player time
        case setTime(TimeSelector)

        /// Set the media subtitle size
        ///
        /// **Note**: Due to VLCKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        ///
        /// **Note**: Does not work on macOS
        case setSubtitleSize(ValueSelector<Int>)

        /// Set the subtitle font using the font name of the given `UIFont`
        ///
        /// **Note**: Does not work on macOS
        case setSubtitleFont(ValueSelector<_PlatformFont>)

        /// Set the subtitle font color using the RGB values of the given `UIColor`
        ///
        /// **Note**: Does not work on macOS
        case setSubtitleColor(ValueSelector<_PlatformColor>)

        /// Add a playback child
        case addPlaybackChild(PlaybackChild)

        /// Play new media given a configuration
        case playNewMedia(VLCVideoPlayer.Configuration)
    }
}
