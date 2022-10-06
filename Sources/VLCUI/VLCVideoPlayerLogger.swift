import Foundation

public protocol VLCVideoPlayerLogger {

    /// Called when the VLCVideoPlayer logs a message
    func vlcVideoPlayer(didLog message: String, at level: VLCVideoPlayer.LoggingLevel)
}
