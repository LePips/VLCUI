import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension _PlatformFont {

    static let defaultSubtitleFont = _PlatformFont.systemFont(ofSize: 14)
}
