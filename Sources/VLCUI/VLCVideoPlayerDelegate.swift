import Combine
import Foundation

public protocol VLCVideoPlayerDelegate {

    /// The subject to send events to the underlying VLCVideoplayer
    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> { get set }

    /// Called when the ticks of the player have changed along with the unit position of the ticks
    /// relative to the estimated total amount of ticks.
    ///
    /// **Note:** position is unstable and may not indicate an accurate position
    func ticksUpdated(_ ticks: Int32, _ position: Float)

    /// Called when the state of the player has changed
    func playerStateUpdated(_ newState: VLCVideoPlayer.State)

    /// Called when the subtitle tracks and their indexes have been parsed
    func didParseSubtitleIndexes(_ indexes: [(Int32, String)])

    /// Called when the audio tracks and their indexes have been parsed
    func didParseAudioIndexes(_ indexes: [(Int32, String)])

    /// Called when the subtitle track index changes
    func subtitleIndexDidChange(_ newIndex: Int32)

    /// Called when the audio track index changes
    func audioIndexDidChange(_ newIndex: Int32)
}

public extension VLCVideoPlayerDelegate {
    func ticksUpdated(_ ticks: Int32, _ position: Float) {}
    func playerStateUpdated(_ newState: VLCVideoPlayer.State) {}
    func didParseSubtitleIndexes(_ indexes: [(Int32, String)]) {}
    func didParseAudioIndexes(_ indexes: [(Int32, String)]) {}
    func subtitleIndexDidChange(_ newIndex: Int32) {}
    func audioIndexDidChange(_ newIndex: Int32) {}
}
