//
//  File.swift
//  
//
//  Created by Ethan Pippin on 11/29/22.
//

import Foundation
import QuartzCore
import UIKit
import AVKit
import Combine

@available(iOS 15.0, *)
class PictureInPictureVideoRenderer {
    
    private var displayLink: CADisplayLink?
    private(set) var isRunning: Bool = false
    private(set) var bufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    private let fps: Int
    private weak var targetView: UIView?
    
    private let pipContainerView = UIView()
    
    init(targetView: UIView, fps: Int) {
        self.targetView = targetView
        self.fps = fps
    }
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        
        if let window = UIApplication.shared._keyWindow {
            pipContainerView.backgroundColor = .clear
            pipContainerView.alpha = 0.0
            window.addSubview(pipContainerView)
            window.sendSubviewToBack(pipContainerView)
            bufferDisplayLayer.backgroundColor = UIColor.clear.cgColor
            bufferDisplayLayer.videoGravity = .resizeAspect
            pipContainerView.layer.addSublayer(bufferDisplayLayer)
        }
        
//        render()
        
        guard fps > 0 else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 1, maximum: Float(fps), preferred: 0)
        displayLink?.add(to: .main, forMode: .default)
    }
    
    func stop() {
        guard isRunning else { return }
        
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc
    func render() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let targetView else {
            stop()
            return
        }
        
        let newImage = targetView.uiImage
        
        let imageRect = CGRect(origin: .zero, size: newImage.size)
        
        self.pipContainerView.frame = imageRect
        self.bufferDisplayLayer.frame = imageRect
        
        guard let newBuffer = newImage.cmSampleBuffer(preferredFramesPerSecond: fps) else { return }
        
        if self.bufferDisplayLayer.status == .failed {
            self.bufferDisplayLayer.flush()
        }
        
        self.bufferDisplayLayer.enqueue(newBuffer)
//        print("enqueued new buffer")
    }
}

private extension UIImage {
    
    func cmSampleBuffer(preferredFramesPerSecond: Int) -> CMSampleBuffer? {
        guard let jpegData = jpegData(compressionQuality: 1.0),
              let cgImage = cgImage else {
                  return nil
              }
        
        let rawPixelSize = CGSize(width: cgImage.width, height: cgImage.height)
        var format: CMFormatDescription?
        
        CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCMVideoCodecType_JPEG,
            width: Int32(rawPixelSize.width),
            height: Int32(rawPixelSize.height),
            extensions: nil,
            formatDescriptionOut: &format
        )
        
        guard let cmBlockBuffer = jpegData.toCMBlockBuffer() else {
            return nil
        }
        
        var size = jpegData.count
        var sampleBuffer: CMSampleBuffer?
        let presentationTimeStamp = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: CMTimeScale(preferredFramesPerSecond))
        let duration = CMTime(value: 1, timescale: CMTimeScale(preferredFramesPerSecond))
        
        var timingInfo = CMSampleTimingInfo(
            duration: duration,
            presentationTimeStamp: presentationTimeStamp,
            decodeTimeStamp: .invalid
        )
        
        CMSampleBufferCreateReady(
            allocator: kCFAllocatorDefault,
            dataBuffer: cmBlockBuffer,
            formatDescription: format,
            sampleCount: 1,
            sampleTimingEntryCount: 1,
            sampleTimingArray: &timingInfo,
            sampleSizeEntryCount: 1,
            sampleSizeArray: &size,
            sampleBufferOut: &sampleBuffer
        )
        
        if sampleBuffer == nil {
            assertionFailure("SampleBuffer is null")
        }
        
        return sampleBuffer
    }
    
}

private func freeBlock(_ refCon: UnsafeMutableRawPointer?, doomedMemoryBlock: UnsafeMutableRawPointer, sizeInBytes: Int) -> Void {
    let unmanagedData = Unmanaged<NSData>.fromOpaque(refCon!)
    unmanagedData.release()
}

private extension Data {
    
    func toCMBlockBuffer() -> CMBlockBuffer? {
        let data = NSMutableData(data: self)
        var source = CMBlockBufferCustomBlockSource()
        source.refCon = Unmanaged.passRetained(data).toOpaque()
        source.FreeBlock = freeBlock
        
        var blockBuffer: CMBlockBuffer?
        let result = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: data.mutableBytes,
            blockLength: data.length,
            blockAllocator: kCFAllocatorNull,
            customBlockSource: &source,
            offsetToData: 0,
            dataLength: data.length,
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        
        if OSStatus(result) != kCMBlockBufferNoErr {
            return nil
        }
        
        guard let buffer = blockBuffer else {
            return nil
        }
        
        assert(CMBlockBufferGetDataLength(buffer) == data.length)
        return buffer
    }
    
}

extension UIView {
    
    enum AssociatedKeys {
        static var avUIKitRenderer = "avUIKitRenderer"
        static var pipVideoController = "PIPVideoController"
    }
    
    @available(iOS 15.0, *)
    var avUIKitRenderer: AVPIPUIKitRenderer? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.avUIKitRenderer) as? AVPIPUIKitRenderer }
        set { objc_setAssociatedObject(self, &AssociatedKeys.avUIKitRenderer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @available(iOS 15.0, *)
    var videoController: AVPIPKitVideoController? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.pipVideoController) as? AVPIPKitVideoController }
        set { objc_setAssociatedObject(self, &AssociatedKeys.pipVideoController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
