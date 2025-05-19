#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
import VLCKit
#elseif os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

extension VLCMediaPlayer {

    func setSubtitleSize(_ size: VLCVideoPlayer.ValueSelector<Int>) {
        let value: Int?

        switch size {
        case .auto:
            value = nil
        case let .absolute(size):
            value = size
        }

        #if !os(macOS)
        perform(
            Selector(("setTextRendererFontSize:")),
            with: value
        )
        #endif
    }

    func setSubtitleFont(_ font: VLCVideoPlayer.ValueSelector<_PlatformFont>) {
        switch font {
        case .auto:
            setSubtitleFont(_PlatformFont.defaultSubtitleFont.fontName)
        case let .absolute(font):
            setSubtitleFont(font.fontName)
        }
    }

    func setSubtitleFont(_ fontName: String) {
        #if !os(macOS)
        perform(
            Selector(("setTextRendererFont:")),
            with: fontName
        )
        #endif
    }

    func setSubtitleColor(_ color: VLCVideoPlayer.ValueSelector<_PlatformColor>) {
        let value: UInt

        switch color {
        case .auto:
            value = _PlatformColor.white.hex
        case let .absolute(fontColor):
            value = fontColor.hex
        }

        #if !os(macOS)
        perform(
            Selector(("setTextRendererFontColor:")),
            with: value
        )
        #endif
    }

    func subtitleTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int>) -> Int {
        guard let indexes = videoSubTitlesIndexes as? [Int] else { return -1 }

        switch track {
        case .auto:
            return indexes.first(where: { $0 != -1 }) ?? -1
        case let .absolute(index):
            return indexes.contains(index) ? index : -1
        }
    }

    func audioTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int>) -> Int {
        guard let indexes = audioTrackIndexes as? [Int] else { return -1 }

        switch track {
        case .auto:
            return indexes.first(where: { $0 != -1 }) ?? -1
        case let .absolute(index):
            return indexes.contains(index) ? index : -1
        }
    }

    func rate(from rate: VLCVideoPlayer.ValueSelector<Float>) -> Float {
        switch rate {
        case .auto:
            return 1
        case let .absolute(speed):
            return speed
        }
    }
}
