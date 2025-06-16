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

    class Proxy: ObservableObject {

        weak var mediaPlayer: VLCMediaPlayer?
        weak var videoPlayerView: UIVLCVideoPlayerView?

        @MainActor
        private var thumbnailHandlers = Set<ThumbnailHandler>()

        public init() {
            self.mediaPlayer = nil
            self.videoPlayerView = nil
        }

        /// Play the current media.
        public func play() {
            mediaPlayer?.play()
        }

        /// Pause the current media.
        public func pause() {
            mediaPlayer?.pause()
        }

        /// Stop the current media.
        public func stop() {
            mediaPlayer?.stop()
        }

        /// Jump forward a given amount of seconds.
        public func jumpForward(_ seconds: Int) {
            mediaPlayer?.jumpForward(seconds.asInt32)
        }

        /// Jump backward a given amount of seconds.
        public func jumpBackward(_ seconds: Int) {
            mediaPlayer?.jumpBackward(seconds.asInt32)
        }

        /// Go to the next frame.
        ///
        /// - Important: media will be paused.
        public func gotoNextFrame() {
            mediaPlayer?.gotoNextFrame()
        }

        /// Set the subtitle track index
        ///
        /// - Important: If there is no valid track with the given index, the track will default to disabled.
        public func setSubtitleTrack(_ index: ValueSelector<Int>) {
            guard let mediaPlayer else { return }
            let newTrackIndex = mediaPlayer.subtitleTrackIndex(from: index)
            mediaPlayer.currentVideoSubTitleIndex = newTrackIndex.asInt32
        }

        /// Set the audio track index.
        ///
        /// - Important: If there is no valid track with the given index, the track will default to disabled.
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

        /// Set the player time.
        public func setTime(_ time: TimeSelector) {
            guard let mediaPlayer,
                  let media = mediaPlayer.media else { return }

            guard time.asTicks >= 0 && time.asTicks <= media.length.intValue else { return }
            mediaPlayer.time = VLCTime(int: time.asTicks.asInt32)
        }

        #if !os(macOS)
        /// Aspect fill depending on the video's content size and the view's bounds, based
        /// on the given percentage of completion.
        public func aspectFill(_ percentage: Float) {
            videoPlayerView?.setAspectFill(with: percentage)
        }

        /// Set the media subtitle size
        ///
        /// - Important: Due to VLCKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        public func setSubtitleSize(_ size: ValueSelector<Int>) {
            mediaPlayer?.setSubtitleSize(size)
        }

        /// Set the subtitle font using the font name of the given `UIFont`.
        public func setSubtitleFont(_ font: ValueSelector<_PlatformFont>) {
            mediaPlayer?.setSubtitleFont(font)
        }

        /// Set the subtitle font using the given font name.
        public func setSubtitleFont(_ fontName: String) {
            mediaPlayer?.setSubtitleFont(fontName)
        }

        /// Set the subtitle font color using the RGB values of the given `UIColor`.
        public func setSubtitleColor(_ color: ValueSelector<_PlatformColor>) {
            mediaPlayer?.setSubtitleColor(color)
        }
        #endif

        /// Add a playback child.
        public func addPlaybackChild(_ child: PlaybackChild) {
            mediaPlayer?.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
        }

        /// Play new media given a configuration.
        public func playNewMedia(_ newConfiguration: Configuration) {
            videoPlayerView?.setupVLCMediaPlayer(with: newConfiguration)
        }

        /// Saves a snapshot of the current media.
        /// File names are automatically generated by VLCKit.
        ///
        /// - Parameter atPath: The directory path where the snapshot will be saved.
        public func saveSnapshot(atPath path: String) {
            guard let mediaPlayer else { return }

            let videoSize = mediaPlayer.videoSize

            mediaPlayer.saveVideoSnapshot(
                at: path,
                withWidth: Int32(videoSize.width),
                andHeight: Int32(videoSize.height)
            )
        }

        /// Starts the recording process.
        ///
        /// - Parameter atPath: The directory path where the recording will be saved
        public func startRecording(atPath path: String) {
            mediaPlayer?.startRecording(atPath: path)
        }

        /// Stops the recording process.
        public func stopRecording() {
            mediaPlayer?.stopRecording()
        }

        /// Fetches a thumbnail image from the media at the given position.
        ///
        /// - Parameter position: The position in the media to take the snapshot at, as a percentage (0.0 to 1.0).
        /// - Parameter size: The size of the image to be captured.
        /// - Returns: `NSImage` or `UIImage` of the thumbnail.
        /// - Throws: `VLCVideoPlayer.ThumbnailError` if an error occurs.
        @MainActor
        public func fetchThumbnail(position: Float, size: CGSize) async throws(ThumbnailError) -> _PlatformImage {
            guard let media = mediaPlayer?.media else {
                throw ThumbnailError.noMedia
            }

            return try await withCheckedContinuation { continuation in
                
                let handler = ThumbnailHandler(
                    continuation: continuation
                ) { [weak self] handler in
                    self?.thumbnailHandlers.remove(handler)
                }
                
                let thumbnailer = VLCMediaThumbnailer(
                    media: media,
                    andDelegate: handler
                )

                self.thumbnailHandlers.insert(handler)
                
                thumbnailer.snapshotPosition = position
                thumbnailer.thumbnailWidth = size.width
                thumbnailer.thumbnailHeight = size.height

                thumbnailer.fetchThumbnail()
            }.get()
        }

        /// Set the video aspect ratio
        ///
        /// - Parameter ratio: The aspect ratio to set using an `AspectRatio` value.
        public func setAspectRatio(_ ratio: VLCVideoPlayer.AspectRatio) {
            guard ratio != .default else {
                mediaPlayer?.videoAspectRatio = nil
                return
            }

            ratio.rawValue.withCString { cString in
                mediaPlayer?.videoAspectRatio = UnsafeMutablePointer(mutating: cString)
            }
        }
    }
}
