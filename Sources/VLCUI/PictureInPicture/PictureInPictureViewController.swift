//
//  File.swift
//  
//
//  Created by Ethan Pippin on 11/29/22.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Combine

@available(iOS 15.0, *)
class PictureInPictureViewController: NSObject {
    
    var isPIPSupported: Bool {
        AVPictureInPictureController.isPictureInPictureSupported()
    }
    
    private let videoRenderer: PictureInPictureVideoRenderer
    private var pipController: AVPictureInPictureController?
    private var pipPossibleObservation: NSKeyValueObservation?
    
    deinit {
        pipPossibleObservation?.invalidate()
    }
    
    init(videoRenderer: PictureInPictureVideoRenderer) {
        self.videoRenderer = videoRenderer
        super.init()
    }
    
    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        if pipController == nil {
            preparePictureInPictureController()
        }
        
        videoRenderer.start()
        
        guard let pipController,
              pipController.isPictureInPicturePossible,
              pipController.isPictureInPictureActive == false
        else {
            return
        }
        
        pipController.startPictureInPicture()
        print("controller called startPictureInPicture")
    }
    
    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        guard videoRenderer.isRunning else { return }
        
        videoRenderer.start()
        pipController?.stopPictureInPicture()
    }
    
    private func preparePictureInPictureController() {
        guard isPIPSupported else { return }
        
        pipController = .init(
            contentSource: .init(
                sampleBufferDisplayLayer: videoRenderer.bufferDisplayLayer,
                playbackDelegate: self
            )
        )
        pipController?.delegate = self
    }
    
    private func exitPictureInPictureController() {
        pipPossibleObservation?.invalidate()
        pipController = nil
    }
}

@available(iOS 15.0, *)
extension PictureInPictureViewController: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        stop()
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        exitPictureInPictureController()
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("did start PIP in controller")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Error with PIP Controller: \(error.localizedDescription)")
    }
}

@available(iOS 15.0, *)
extension PictureInPictureViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {}
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}
    
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        false
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
