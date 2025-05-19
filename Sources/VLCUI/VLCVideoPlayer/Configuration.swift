#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension VLCVideoPlayer {

    // Configuration for VLCMediaPlayer
    class Configuration {
        public var url: URL
        public var autoPlay: Bool = true
        public var startTime: TimeSelector = .ticks(0)
        public var aspectFill: Bool = false
        public var replay: Bool = false
        public var rate: ValueSelector<Float> = .auto
        public var subtitleIndex: ValueSelector<Int> = .auto
        public var audioIndex: ValueSelector<Int> = .auto
        public var subtitleSize: ValueSelector<Int> = .auto
        public var subtitleFont: ValueSelector<_PlatformFont> = .auto
        public var subtitleColor: ValueSelector<_PlatformColor> = .auto
        public var playbackChildren: [PlaybackChild] = []
        public var options: [String: Any] = [:]

        public init(url: URL) {
            self.url = url
        }
    }
}
