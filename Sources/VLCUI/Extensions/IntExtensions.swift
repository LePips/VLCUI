import Foundation

public extension Int {

    // Round down to nearest thousand
    var roundDownNearestThousand: Int {
        (self / 1000) * 1000
    }
}

extension Int {

    var asInt32: Int32 {
        Int32(self)
    }
}

extension Int32 {

    var asInt: Int {
        Int(self)
    }
}
