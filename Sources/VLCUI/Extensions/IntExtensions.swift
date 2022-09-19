import Foundation

public extension Int32 {

    // Round down to nearest thousand
    var roundDownNearestThousand: Int32 {
        (self / 1000) * 1000
    }
}
