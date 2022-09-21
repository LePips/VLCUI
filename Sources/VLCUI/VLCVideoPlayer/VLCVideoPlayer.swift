import Foundation
import SwiftUI

public struct VLCVideoPlayer: _PlatformRepresentable {

    // MARK: Implementation

    private var configuration: VLCVideoPlayer.Configuration
    private var delegate: VLCVideoPlayerDelegate

    #if os(macOS)
    public func makeNSView(context: Context) -> UIVLCVideoPlayerView {
        makeVideoPlayerView()
    }

    public func updateNSView(_ nsView: UIVLCVideoPlayerView, context: Context) {}
    #else
    public func makeUIView(context: Context) -> UIVLCVideoPlayerView {
        makeVideoPlayerView()
    }

    public func updateUIView(_ uiView: UIVLCVideoPlayerView, context: Context) {}
    #endif

    private func makeVideoPlayerView() -> UIVLCVideoPlayerView {
        UIVLCVideoPlayerView(
            configuration: configuration,
            delegate: delegate
        )
    }
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
