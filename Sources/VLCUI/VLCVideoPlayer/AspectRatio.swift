//
//  File.swift
//  VLCUI
//
//  Created by Nevzat BOZKURT on 13.05.2025.
//

import Foundation

public extension VLCVideoPlayer {
    /// Set the video aspect ratio
    /// - Parameter ratio: The aspect ratio to set using the `AspectRatio` enum.
    enum AspectRatio: String {
        case `default` = "default"
        case widescreen16x9 = "16:9"
        case standard4x3 = "4:3"
        case widescreen16x10 = "16:10"
        case square1x1 = "1:1"
        case cinema221x1 = "2.21:1"
        case cinema235x1 = "2.35:1"
        case cinema239x1 = "2.39:1"
        case computer5x4 = "5:4"
        case super16mm5x3 = "5:3"
        case cinema185x1 = "1.85:1"
        case cinema220x1 = "2.20:1"
    }
}
