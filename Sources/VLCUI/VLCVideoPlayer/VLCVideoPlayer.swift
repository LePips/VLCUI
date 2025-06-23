import Combine
import SwiftUI

public struct VLCVideoPlayer: _PlatformRepresentable {

    private var configuration: VLCVideoPlayer.Configuration
    private var proxy: VLCVideoPlayer.Proxy?
    private var onTicksUpdated: (Int, VLCVideoPlayer.PlaybackInformation) -> Void
    private var onStateUpdated: (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void
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
            onTicksUpdated: onTicksUpdated,
            onStateUpdated: onStateUpdated,
            loggingInfo: loggingInfo
        )
    }
}

public extension VLCVideoPlayer {

    init(configuration: VLCVideoPlayer.Configuration) {
        self.init(
            configuration: configuration,
            proxy: nil,
            onTicksUpdated: { _, _ in },
            onStateUpdated: { _, _ in },
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

    /// Sets the action that fires when the media ticks have been updated
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
    func onSecondsUpdated(_ action: @escaping (Duration, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        var copy = self
        copy.onTicksUpdated = { ticks, playbackInfo in
            let seconds = Duration.milliseconds(ticks)
            action(seconds, playbackInfo)
        }
        return copy
    }

    /// Sets the action that fires when the media ticks have been updated
    @available(iOS, deprecated: 16.0, message: "Use `onDurationUpdated` instead")
    @available(tvOS, deprecated: 16.0, message: "Use `onDurationUpdated` instead")
    @available(macOS, deprecated: 13.0, message: "Use `onDurationUpdated` instead")
    func onTicksUpdated(_ action: @escaping (Int, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onTicksUpdated, with: action)
    }

    /// Sets the action that fires when the media state has been updated
    func onStateUpdated(_ action: @escaping (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onStateUpdated, with: action)
    }

    func logger(_ logger: VLCVideoPlayerLogger, level: LoggingLevel) -> Self {
        copy(modifying: \.loggingInfo, with: (logger, level))
    }
}
