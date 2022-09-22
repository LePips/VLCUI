import Foundation
import SwiftUI

public struct VLCVideoPlayer: _PlatformRepresentable {

    // MARK: Implementation

    private var configuration: VLCVideoPlayer.Configuration
    private var delegate: VLCVideoPlayerDelegate
    private var logger: VLCVideoPlayerLogger

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
            delegate: delegate,
            logger: logger
        )
    }
}

public extension VLCVideoPlayer {

    init(configuration: VLCVideoPlayer.Configuration) {
        self.configuration = configuration
        self.delegate = DefaultVideoPlayerDelegate()
        self.logger = DefaultVideoPlayerLogger()
    }

    init(url: URL) {
        self.init(configuration: VLCVideoPlayer.Configuration(url: url))
    }

    init(_ configure: @escaping () -> VLCVideoPlayer.Configuration) {
        self.init(configuration: configure())
    }

    func delegate(_ delegate: VLCVideoPlayerDelegate) -> Self {
        var copy = self
        copy.delegate = delegate
        return copy
    }

    func logger(_ logger: VLCVideoPlayerLogger) -> Self {
        var copy = self
        copy.logger = logger
        return copy
    }
}
