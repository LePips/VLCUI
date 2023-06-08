import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
import VLCKit
#elseif os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

public extension VLCVideoPlayer {
    class Proxy: ObservableObject, VLCMediaThumbnailerDelegate {
        weak var mediaPlayer: VLCMediaPlayer?
        weak var videoPlayerView: UIVLCVideoPlayerView?
        
        private var onTakeMediaThumbnailer: ((VLCMediaThumbnailer, CGImage) -> Void)?
        private var onTakeMediaThumbnailerDidTimeOut: ((VLCMediaThumbnailer) -> Void)?
        
        public init() {
            self.mediaPlayer = nil
            self.videoPlayerView = nil
        }
        
        /// Play the current media
        public func play() {
            mediaPlayer?.play()
        }
        
        /// Pause the current media
        public func pause() {
            mediaPlayer?.pause()
        }
        
        /// Stop the current media
        public func stop() {
            mediaPlayer?.stop()
        }
        
        /// Jump forward a given amount of seconds
        public func jumpForward(_ seconds: Int) {
            mediaPlayer?.jumpForward(seconds.asInt32)
        }
        
        /// Jump backward a given amount of seconds
        public func jumpBackward(_ seconds: Int) {
            mediaPlayer?.jumpBackward(seconds.asInt32)
        }
        
        /// Go to the next frame
        ///
        /// **Note**: media will be paused
        public func gotoNextFrame() {
            mediaPlayer?.gotoNextFrame()
        }
        
        /// Set the subtitle track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        public func setSubtitleTrack(_ index: ValueSelector<Int>) {
            guard let mediaPlayer else { return }
            let newTrackIndex = mediaPlayer.subtitleTrackIndex(from: index)
            mediaPlayer.currentVideoSubTitleIndex = newTrackIndex.asInt32
        }
        
        /// Set the audio track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        public func setAudioTrack(_ index: ValueSelector<Int>) {
            guard let mediaPlayer else { return }
            let newTrackIndex = mediaPlayer.audioTrackIndex(from: index)
            mediaPlayer.currentAudioTrackIndex = newTrackIndex.asInt32
        }
        
        /// Set the subtitle delay
        public func setSubtitleDelay(_ interval: TimeSelector) {
            let delay = interval.asTicks * 1000
            mediaPlayer?.currentVideoSubTitleDelay = delay
        }
        
        /// Set the audio delay
        public func setAudioDelay(_ interval: TimeSelector) {
            let delay = interval.asTicks * 1000
            mediaPlayer?.currentAudioPlaybackDelay = delay
        }
        
        /// Set the player rate
        public func setRate(_ rate: ValueSelector<Float>) {
            guard let mediaPlayer else { return }
            let newRate = mediaPlayer.rate(from: rate)
            mediaPlayer.fastForward(atRate: newRate)
        }
        
        /// Aspect fill depending on the video's content size and the view's bounds, based
        /// on the given percentage of completion
        ///
        /// **Note**: Does not work on macOS
        public func aspectFill(_ percentage: Float) {
            videoPlayerView?.setAspectFill(with: percentage)
        }
        
        /// Set the player time
        public func setTime(_ time: TimeSelector) {
            guard let mediaPlayer,
                  let media = mediaPlayer.media else { return }
            
            guard time.asTicks >= 0, time.asTicks <= media.length.intValue else { return }
            mediaPlayer.time = VLCTime(int: time.asTicks.asInt32)
        }
        
        /// Set the media subtitle size
        ///
        /// **Note**: Due to VLCKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleSize(_ size: ValueSelector<Int>) {
            mediaPlayer?.setSubtitleSize(size)
        }
        
        /// Set the subtitle font using the font name of the given `UIFont`
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleFont(_ font: ValueSelector<_PlatformFont>) {
            mediaPlayer?.setSubtitleFont(font)
        }
        
        /// Set the subtitle font using the given font name
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleFont(_ fontName: String) {
            mediaPlayer?.setSubtitleFont(fontName)
        }
        
        /// Set the subtitle font color using the RGB values of the given `UIColor`
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleColor(_ color: ValueSelector<_PlatformColor>) {
            mediaPlayer?.setSubtitleColor(color)
        }
        
        /// Add a playback child
        public func addPlaybackChild(_ child: PlaybackChild) {
            mediaPlayer?.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
        }
        
        /// Play new media given a configuration
        public func playNewMedia(_ newConfiguration: Configuration) {
            videoPlayerView?.setupVLCMediaPlayer(with: newConfiguration)
        }
        
        public func fetchThumbnailer(position: Float, width: Float, height: Float) -> CGImage? {
            let semaphore = DispatchSemaphore(value: 0)
            var resultImage: CGImage?
            
            if let media = self.mediaPlayer?.media {
                let thumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)
                thumbnailer.thumbnailWidth = CGFloat(width)
                thumbnailer.thumbnailHeight = CGFloat(height)
                thumbnailer.snapshotPosition = position
                thumbnailer.fetchThumbnail()
                
                // This block will be called when the thumbnail is ready or an error occurred
                self.onTakeMediaThumbnailer = { _, thumbnail in
                    resultImage = thumbnail
                    semaphore.signal()
                }
                self.onTakeMediaThumbnailerDidTimeOut = { _ in
                    resultImage = nil
                    semaphore.signal()
                }
                _ = semaphore.wait(timeout: .distantFuture)
                return resultImage
            }
            return nil
        }
        
        func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
            onTakeMediaThumbnailer?(mediaThumbnailer, thumbnail)
        }
        
        func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
            onTakeMediaThumbnailerDidTimeOut?(mediaThumbnailer)
        }
    }
}
