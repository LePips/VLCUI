import Combine
import Foundation

public protocol VLCVideoPlayerDelegate {

    /// The subject to send events to the underlying VLCVideoplayer
    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> { get set }

    /// Called when the ticks of the player change
    func vlcVideoPlayer(didUpdateTicks ticks: Int32, with playbackInformation: VLCVideoPlayer.PlaybackInformation)

    /// Called when the VLCVideoPlayer state has been updated
    func vlcVideoPlayer(didUpdateState state: VLCVideoPlayer.State, with playbackInformation: VLCVideoPlayer.PlaybackInformation)
}

public extension VLCVideoPlayerDelegate {
    func vlcVideoPlayer(didUpdateTicks ticks: Int32, with playbackInformation: VLCVideoPlayer.PlaybackInformation) {}
    func vlcVideoPlayer(didUpdateState state: VLCVideoPlayer.State, with playbackInformation: VLCVideoPlayer.PlaybackInformation) {}
}

class DefaultVideoPlayerDelegate: VLCVideoPlayerDelegate {
    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> = .init(nil)
}
