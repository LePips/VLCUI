import Combine
import Foundation
import SwiftUI

public struct VLCVideoPlayer: _PlatformRepresentable {

    private var configuration: VLCVideoPlayer.Configuration
    private var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never>
    private var onTicksUpdated: (Int32, VLCVideoPlayer.PlaybackInformation) -> Void
    private var onStateUpdated: (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void
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
            eventSubject: eventSubject,
            onTicksUpdated: onTicksUpdated,
            onStateUpdated: onStateUpdated,
            logger: logger
        )
    }
}

public extension VLCVideoPlayer {

    init(configuration: VLCVideoPlayer.Configuration) {
        self.configuration = configuration
        self.eventSubject = .init(nil)
        self.onTicksUpdated = { _, _ in }
        self.onStateUpdated = { _, _ in }
        self.logger = DefaultVideoPlayerLogger()
    }

    init(url: URL) {
        self.init(configuration: VLCVideoPlayer.Configuration(url: url))
    }

    init(_ configure: @escaping () -> VLCVideoPlayer.Configuration) {
        self.init(configuration: configure())
    }

    /// Sets the event subject for subscribing to player command events
    func eventSubject(_ eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never>) -> Self {
        var copy = self
        copy.eventSubject = eventSubject
        return copy
    }

    /// Sets the action that fires when the media ticks have been updated
    func onTicksUpdated(_ action: @escaping (Int32, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        var copy = self
        copy.onTicksUpdated = action
        return copy
    }

    /// Sets the action that fires when the media state has been updated
    func onStateUpdated(_ action: @escaping (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void) -> Self {
        var copy = self
        copy.onStateUpdated = action
        return copy
    }

    func logger(_ logger: VLCVideoPlayerLogger) -> Self {
        var copy = self
        copy.logger = logger
        return copy
    }
}
