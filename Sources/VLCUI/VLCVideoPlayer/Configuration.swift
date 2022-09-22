import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension VLCVideoPlayer {

    // Configuration for VLCMediaPlayer
    class Configuration {
        public var url: URL
        public var autoPlay: Bool = false
        public var startTime: TimeSelector = .ticks(0)
        public var aspectFill: Bool = false
        public var restartOnEnded: Bool = false
        public var playbackSpeed: ValueSelector<Float> = .auto
        public var subtitleIndex: ValueSelector<Int32> = .auto
        public var audioIndex: ValueSelector<Int32> = .auto
        public var subtitleSize: ValueSelector<Int> = .auto
        public var subtitleFont: ValueSelector<_PlatformFont> = .auto
        public var subtitleColor: ValueSelector<_PlatformColor> = .auto
        public var playbackChildren: [PlaybackChild] = []
        public var options: [String: Any] = [:]
        public var isLogging: Bool = false
        public var loggingLevel: LoggingLevel = .info

        public init(url: URL) {
            self.url = url
        }
    }
}
