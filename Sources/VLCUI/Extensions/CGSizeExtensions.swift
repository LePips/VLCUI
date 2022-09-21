import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension CGSize {

    static func aspectFill(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let widthRatio = minimumSize.width / aspectRatio.width
        let heightRatio = minimumSize.height / aspectRatio.height

        if heightRatio > widthRatio {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
        } else if widthRatio > heightRatio {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
        }

        return minimumSize
    }

    func scale(other: CGSize) -> CGFloat {
        if height > other.height {
            return height / other.height
        } else {
            return width / other.width
        }
    }
}
