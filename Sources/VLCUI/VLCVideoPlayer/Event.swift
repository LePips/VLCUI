import Foundation
import UIKit

public extension VLCVideoPlayer {

    // Possible events to send to the underlying VLC media player
    enum Event {
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
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        case setSubtitleTrack(ValueSelector<Int32>)

        /// Set the audio track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        case setAudioTrack(ValueSelector<Int32>)

        /// Fast forward at a given rate
        case fastForward(ValueSelector<Float>)

        /// Aspect fill depending on the video's content size and the view's bounds
        case aspectFill(Bool)

        /// Set the player time
        case setTime(TimeSelector)

        /// Set the media subtitle size
        ///
        /// **Note**: Due to VLCKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        case setSubtitleSize(ValueSelector<Int>)

        /// Set the subtitle font using the font name of the given `UIFont`
        case setSubtitleFont(ValueSelector<UIFont>)

        /// Set the subtitle font color using the RGB values of the given `UIColor`
        case setSubtitleColor(ValueSelector<UIColor>)

        /// Add a playback child
        case addPlaybackChild(PlaybackChild)
    }
}
