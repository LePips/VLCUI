import Foundation
import UIKit

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

extension CGSize {
    static func aspectFill(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let mW = minimumSize.width / aspectRatio.width
        let mH = minimumSize.height / aspectRatio.height

        if mH > mW {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
        } else if mW > mH {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
        }

        return minimumSize
    }
}

extension VLCMediaPlayer {
    func setSubtitleSize(_ size: VLCVideoPlayer.FontSizeSelector) {
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

    func setSubtitleFont(_ fontName: VLCVideoPlayer.FontNameSelector) {
        let value: String

        switch fontName {
        case .auto:
            value = UIFont.defaultSubtitleFont.fontName
        case let .absolute(fontName):
            value = fontName
        }

        perform(
            Selector(("setTextRendererFont:")),
            with: value
        )
    }
}

extension UIFont {
    static let defaultSubtitleFont = UIFont.systemFont(ofSize: 14)
}

public extension Int32 {

    // Provided utility for rounding to nearest thousand
    // when using ticks
    var roundNearestThousand: Int32 {
        (self / 1000) * 1000
    }
}
