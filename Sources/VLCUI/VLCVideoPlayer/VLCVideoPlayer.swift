import Foundation
import SwiftUI

public struct VLCVideoPlayer: UIViewControllerRepresentable {

    // MARK: Implementation

    private let playbackURL: URL
    private var configure: (Configuration) -> Void
    private var delegate: VLCVideoPlayerDelegate

    public func makeUIViewController(context: Context) -> UIVLCVideoPlayerViewController {
        let configuration = VLCVideoPlayer.Configuration()
        configure(configuration)

        return UIVLCVideoPlayerViewController(
            url: playbackURL,
            configuration: configuration,
            delegate: delegate
        )
    }

    public func updateUIViewController(_ uiViewController: UIVLCVideoPlayerViewController, context: Context) {}
}

public extension VLCVideoPlayer {
    init(url: URL) {
        self.playbackURL = url
        self.configure = { _ in }
        self.delegate = DefaultVideoPlayerDelegate()
    }

    func configure(_ configure: @escaping (VLCVideoPlayer.Configuration) -> Void) -> Self {
        var copy = self
        copy.configure = configure
        return copy
    }

    func delegate(_ delegate: VLCVideoPlayerDelegate) -> Self {
        var copy = self
        copy.delegate = delegate
        return copy
    }
}
