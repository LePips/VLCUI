import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension _PlatformView {
    
    func apply(transform: CGAffineTransform) {
        #if os(macOS)
        layer?.setAffineTransform(transform)
        #else
        self.transform = transform
        #endif
    }
}
