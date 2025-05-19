public extension VLCVideoPlayer {

    enum ThumbnailError: Error {
        case noMedia
        case thumbnailerInitializationFailed
        case timeout
    }
}
