import Foundation
import UIKit

public extension VLCVideoPlayer {

    // Configuration for VLCMediaPlayer
    class Configuration {
        public var url: URL
        public var autoPlay: Bool = false
        public var startTime: TimeSelector = .ticks(0)
        public var aspectFill: Bool = false
        public var playbackSpeed: ValueSelector<Float> = .auto
        public var subtitleIndex: ValueSelector<Int32> = .auto
        public var audioIndex: ValueSelector<Int32> = .auto
        public var subtitleSize: ValueSelector<Int> = .auto
        public var subtitleFont: ValueSelector<UIFont> = .auto
        public var subtitleColor: ValueSelector<UIColor> = .auto
        public var playbackChildren: [PlaybackChild] = []
        public var options: [String: Any] = [:]

        public init(url: URL) {
            self.url = url
        }
    }
}
