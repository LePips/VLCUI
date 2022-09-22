import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension _PlatformView {

    func apply(transform: CGAffineTransform) {
        #if !os(macOS)
        self.transform = transform
        #endif
    }

    func scale(x: CGFloat, y: CGFloat) {
        let transform = CGAffineTransform(scaleX: x, y: y)

        #if !os(macOS)
        self.transform = transform
        #endif
    }
}
