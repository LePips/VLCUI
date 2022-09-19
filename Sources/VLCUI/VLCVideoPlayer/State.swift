import Foundation

public extension VLCVideoPlayer {

    // Wrapper so that VLCKit imports are not necessary
    enum State: Int {
        case stopped
        case opening
        case buffering
        case ended
        case error
        case playing
        case paused
        case esAdded
    }
}
