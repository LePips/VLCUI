import Foundation
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension CALayer {
    
    func recursive_render(in context: CGContext) {
        render(in: context)
        
        sublayers?.forEach({ $0.recursive_render(in: context) })
    }
}

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
    
    var uiImage: UIImage {
        UIGraphicsImageRenderer(bounds: bounds).image { context in
            layer.render(in: context.cgContext)
        }
    }
}

extension View {

    func copy<Value>(modifying keyPath: WritableKeyPath<Self, Value>, with newValue: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = newValue
        return copy
    }
}
