import Combine
import Foundation
import SwiftUI

public struct VLCVideoPlayer: _PlatformRepresentable {

    private var configuration: VLCVideoPlayer.Configuration
    private var proxy: VLCVideoPlayer.Proxy?
    private var onSecondsUpdated: (TimeInterval, VLCVideoPlayer.PlaybackInformation) -> Void
    private var onStateUpdated: (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void
    private var onTicksUpdated: (Int, VLCVideoPlayer.PlaybackInformation) -> Void
    private var loggingInfo: (VLCVideoPlayerLogger, LoggingLevel)?

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
            proxy: proxy,
            onSecondsUpdated: onSecondsUpdated,
            onStateUpdated: onStateUpdated,
            onTicksUpdated: onTicksUpdated,
            loggingInfo: loggingInfo
        )
    }
}

public extension VLCVideoPlayer {

    init(configuration: VLCVideoPlayer.Configuration) {
        self.init(
            configuration: configuration,
            proxy: nil,
            onSecondsUpdated: { _, _ in },
            onStateUpdated: { _, _ in },
            onTicksUpdated: { _, _ in },
            loggingInfo: nil
        )
    }

    init(url: URL) {
        self.init(configuration: VLCVideoPlayer.Configuration(url: url))
    }

    init(_ configure: @escaping () -> VLCVideoPlayer.Configuration) {
        self.init(configuration: configure())
    }

    /// Sets the proxy for events
    func proxy(_ proxy: VLCVideoPlayer.Proxy) -> Self {
        copy(modifying: \.proxy, with: proxy)
    }
    
    /// Sets the action that fires when the media seconds have been updated
    func onSecondsUpdated(_ action: @escaping (TimeInterval, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onSecondsUpdated, with: action)
    }
    
    /// Sets the action that fires when the media state has been updated
    func onStateUpdated(_ action: @escaping (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onStateUpdated, with: action)
    }

    /// Sets the action that fires when the media ticks have been updated
    func onTicksUpdated(_ action: @escaping (Int, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onTicksUpdated, with: action)
    }

    func logger(_ logger: VLCVideoPlayerLogger, level: LoggingLevel) -> Self {
        copy(modifying: \.loggingInfo, with: (logger, level))
    }
}
