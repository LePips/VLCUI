import Combine
import Foundation
import VLCUI

class ContentViewModel: ObservableObject, VLCVideoPlayerDelegate {

    @Published
    var ticks: Int32 = 0
    @Published
    var playerState: VLCVideoPlayer.State = .opening
    @Published
    var position: Float = 0
    @Published
    var totalTicks: Int32 = 0

    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> = .init(nil)

    var configuration: VLCVideoPlayer.Configuration {
        let configuration = VLCVideoPlayer
            .Configuration(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        configuration.autoPlay = true
        return configuration
    }

    func setCustomPosition(_ position: Float) {
        self.position = position
    }

    func vlcVideoPlayer(didUpdateTicks ticks: Int32, with playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        self.ticks = ticks
        self.position = playbackInformation.position

        self.totalTicks = playbackInformation.length
    }

    func vlcVideoPlayer(didUpdateState state: VLCVideoPlayer.State, with playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        self.playerState = state

        if state == .error {
            print("An error has occurred")
        }
    }
}
