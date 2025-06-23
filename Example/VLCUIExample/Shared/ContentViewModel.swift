import Combine
import Foundation
import VLCUI

class ContentViewModel: ObservableObject {

    @Published
    var seconds: Duration = .zero
    @Published
    var playerState: VLCVideoPlayer.State = .opening
    @Published
    var position: Float = 0
    @Published
    var totalSeconds: Duration = .zero
    @Published
    var isRecording = false

    let proxy: VLCVideoPlayer.Proxy = .init()

    var configuration: VLCVideoPlayer.Configuration {
        var configuration = VLCVideoPlayer
            .Configuration(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        configuration.autoPlay = true

        return configuration
    }

    var positiveSeconds: Int {
        Int(seconds.components.seconds)
    }

    var negativeSeconds: Int {
        Int((totalSeconds - seconds).components.seconds)
    }

    func onStateUpdated(_ newState: VLCVideoPlayer.State, _ playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        playerState = newState
    }

    func onSecondsUpdated(_ newSeconds: Duration, _ playbackInformation: VLCVideoPlayer.PlaybackInformation) {
        seconds = newSeconds
        totalSeconds = .milliseconds(playbackInformation.length)
        position = playbackInformation.position
    }
}
