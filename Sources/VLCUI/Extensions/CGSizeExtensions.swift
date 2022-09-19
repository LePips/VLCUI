import Foundation
import UIKit

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
