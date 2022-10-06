import Foundation

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
        let value: String

        switch font {
        case .auto:
            value = _PlatformFont.defaultSubtitleFont.fontName
        case let .absolute(font):
            value = font.fontName
        }

        #if !os(macOS)
        perform(
            Selector(("setTextRendererFont:")),
            with: value
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

    func subtitleTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int32>) -> Int32 {
        guard let indexes = videoSubTitlesIndexes as? [Int32] else { return -1 }

        switch track {
        case .auto:
            return indexes.first(where: { $0 != -1 }) ?? -1
        case let .absolute(index):
            return indexes.contains(index) ? index : -1
        }
    }

    func audioTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int32>) -> Int32 {
        guard let indexes = audioTrackIndexes as? [Int32] else { return -1 }

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
