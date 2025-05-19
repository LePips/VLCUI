#if os(macOS)
import VLCKit
#elseif os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

extension VLCVideoPlayer {

    @MainActor
    class ThumbnailHandler: NSObject, VLCMediaThumbnailerDelegate {

        private var continuation: CheckedContinuation<Result<_PlatformImage, ThumbnailError>, Never>?
        private var thumbnailer: VLCMediaThumbnailer?
        private var onCleanup: (ThumbnailHandler) -> Void

        private let instance = UUID()

        init(
            thumbnailer: VLCMediaThumbnailer,
            continuation: CheckedContinuation<Result<_PlatformImage, ThumbnailError>, Never>,
            onCleanup: @escaping (ThumbnailHandler) -> Void
        ) {
            self.thumbnailer = thumbnailer
            self.continuation = continuation
            self.onCleanup = onCleanup
            super.init()

            thumbnailer.delegate = self
        }

        func fetchThumbnail(position: Float, size: CGSize) {
            thumbnailer?.snapshotPosition = position
            thumbnailer?.thumbnailWidth = size.width
            thumbnailer?.thumbnailHeight = size.height

            thumbnailer?.fetchThumbnail()
        }

        // VLCMediaThumbnailerDelegate methods can be called from any thread.
        // They need to be nonisolated and then dispatch to the main actor if they interact
        // with @MainActor-isolated properties or methods.
        public nonisolated func mediaThumbnailer(
            _ mediaThumbnailer: VLCMediaThumbnailer,
            didFinishThumbnail thumbnail: CGImage
        ) {
            #if os(macOS)
            let image = _PlatformImage(
                cgImage: thumbnail,
                size: NSSize(width: thumbnail.width, height: thumbnail.height)
            )
            #else
            let image = _PlatformImage(cgImage: thumbnail)
            #endif

            Task { @MainActor in
                self.continuation?.resume(success: image)
                self.cleanupOnMainActor()
            }
        }

        public nonisolated func mediaThumbnailerDidTimeOut(
            _ mediaThumbnailer: VLCMediaThumbnailer
        ) {
            Task { @MainActor in
                self.continuation?.resume(failure: .timeout)
                self.cleanupOnMainActor()
            }
        }

        @MainActor
        private func cleanupOnMainActor() {
            continuation = nil
            thumbnailer?.delegate = nil
            thumbnailer = nil
            onCleanup(self)
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? ThumbnailHandler else { return false }
            return self.instance == other.instance
        }

        override var hash: Int {
            instance.hashValue
        }
    }
}
