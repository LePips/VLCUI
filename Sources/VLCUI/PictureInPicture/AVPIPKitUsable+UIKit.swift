//
//  AVPIPKitUsable+UIKit.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/08.
//

import Foundation
import UIKit
import Combine

@available(iOS 15.0, *)
protocol AVPIPUIKitUsable: AVPIPKitUsable {
    
    var pipTargetView: UIView { get }
    var renderPolicy: AVPIPKitRenderPolicy { get }
    var exitPublisher: AnyPublisher<Void, Never> { get }
    
}

@available(iOS 15.0, *)
extension AVPIPUIKitUsable {
    
    var renderPolicy: AVPIPKitRenderPolicy {
        .preferredFramesPerSecond(UIScreen.main.maximumFramesPerSecond)
    }
}
