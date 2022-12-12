//
//  AVPIPKitUsable.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit
import AVKit

@available(iOS 15.0, *)
enum AVPIPKitRenderPolicy {
    
    case once
    case preferredFramesPerSecond(Int)
    
}

@available(iOS 15.0, *)
extension AVPIPKitRenderPolicy {
    
    var preferredFramesPerSecond: Int {
        switch self {
        case .once:
            return 1
        case .preferredFramesPerSecond(let preferredFramesPerSecond):
            return preferredFramesPerSecond
        }
    }
    
}

@available(iOS 15.0, *)
protocol AVPIPKitUsable {
    
    var renderer: AVPIPKitRenderer { get }
    
    func startPictureInPicture()
    func stopPictureInPicture()
    
}
