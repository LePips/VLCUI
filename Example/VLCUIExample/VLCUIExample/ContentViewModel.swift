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

    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> = .init(nil)

    func setCustomPosition(_ position: Float) {
        self.position = position
        self.eventSubject.send(.setPosition(position))
    }

    func ticksUpdated(_ ticks: Int32, _ position: Float) {
        self.ticks = ticks
        self.position = position
    }

    func playerStateUpdated(_ newState: VLCVideoPlayer.State) {
        self.playerState = newState

        if newState == .error {
            print("error occurred")
        }
    }
}
