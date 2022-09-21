import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension _PlatformColor {

    var coreImageColor: CIColor {
        #if os(macOS)
        CIColor(color: self)!
        #else
        CIColor(color: self)
        #endif
    }

    var hex: UInt {
        let red = UInt(coreImageColor.red * 255 + 0.5)
        let green = UInt(coreImageColor.green * 255 + 0.5)
        let blue = UInt(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }
}
