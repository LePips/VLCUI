import Combine
import Foundation
import VLCUI

class ContentViewModel: ObservableObject {

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

    var positiveTimeLabel: String {
        (ticks.roundDownNearestThousand / 1000).timeLabel
    }

    var negativeTimeLabel: String {
        ((totalTicks.roundDownNearestThousand - ticks.roundDownNearestThousand) / 1000).timeLabel
    }

    func setCustomPosition(_ position: Float) {
        self.position = position
    }
}
