public extension VLCVideoPlayer {

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
