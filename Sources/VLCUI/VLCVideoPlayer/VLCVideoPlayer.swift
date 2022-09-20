import Foundation
import SwiftUI

public struct VLCVideoPlayer: UIViewControllerRepresentable {

    // MARK: Implementation

    private var configuration: VLCVideoPlayer.Configuration
    private var delegate: VLCVideoPlayerDelegate

    public func makeUIViewController(context: Context) -> UIVLCVideoPlayerViewController {
        UIVLCVideoPlayerViewController(
            configuration: configuration,
            delegate: delegate
        )
    }

    public func updateUIViewController(_ uiViewController: UIVLCVideoPlayerViewController, context: Context) {}
}

public extension VLCVideoPlayer {

    init(url: URL) {
        self.configuration = VLCVideoPlayer.Configuration(url: url)
        self.delegate = DefaultVideoPlayerDelegate()
    }

    init(configuration: VLCVideoPlayer.Configuration) {
        self.configuration = configuration
        self.delegate = DefaultVideoPlayerDelegate()
    }

    init(_ configure: @escaping () -> VLCVideoPlayer.Configuration) {
        self.configuration = configure()
        self.delegate = DefaultVideoPlayerDelegate()
    }

    func delegate(_ delegate: VLCVideoPlayerDelegate) -> Self {
        var copy = self
        copy.delegate = delegate
        return copy
    }
}
