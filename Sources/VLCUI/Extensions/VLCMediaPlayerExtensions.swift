import Foundation
import UIKit

#if os(tvOS)
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

        perform(
            Selector(("setTextRendererFontSize:")),
            with: value
        )
    }

    func setSubtitleFont(_ font: VLCVideoPlayer.ValueSelector<UIFont>) {
        let value: String

        switch font {
        case .auto:
            value = UIFont.defaultSubtitleFont.fontName
        case let .absolute(font):
            value = font.fontName
        }

        perform(
            Selector(("setTextRendererFont:")),
            with: value
        )
    }

    func setSubtitleColor(_ color: VLCVideoPlayer.ValueSelector<UIColor>) {
        let value: UInt

        switch color {
        case .auto:
            value = UIColor.white.hex
        case let .absolute(fontColor):
            value = fontColor.hex
        }

        perform(
            Selector(("setTextRendererFontColor:")),
            with: value
        )
    }

    func subtitleTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int32>) -> Int32 {
        guard let indexes = videoSubTitlesIndexes as? [Int32] else { return -1 }

        let trackIndex: Int32

        switch track {
        case .auto:
            if let firstValidTrackIndex = indexes.first(where: { $0 != -1 }) {
                trackIndex = firstValidTrackIndex
            } else {
                trackIndex = -1
            }
        case let .absolute(index):
            if indexes.contains(index) {
                trackIndex = index
            } else {
                trackIndex = -1
            }
        }

        return trackIndex
    }

    func audioTrackIndex(from track: VLCVideoPlayer.ValueSelector<Int32>) -> Int32 {
        guard let indexes = audioTrackIndexes as? [Int32] else { return -1 }

        let trackIndex: Int32

        switch track {
        case .auto:
            if let firstValidTrackIndex = indexes.first(where: { $0 != -1 }) {
                trackIndex = firstValidTrackIndex
            } else {
                trackIndex = -1
            }
        case let .absolute(index):
            if indexes.contains(index) {
                trackIndex = index
            } else {
                trackIndex = -1
            }
        }

        return trackIndex
    }

    func fastForwardSpeed(from speed: VLCVideoPlayer.ValueSelector<Float>) -> Float {
        let newSpeed: Float
        switch speed {
        case .auto:
            newSpeed = 1
        case let .absolute(speed):
            newSpeed = speed
        }
        return newSpeed
    }
}
