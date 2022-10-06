import Combine
import Foundation
import MediaPlayer

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
import VLCKit
#elseif os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

// TODO: Cleanup constructPlaybackInformation

public class UIVLCVideoPlayerView: _PlatformView {

    private lazy var videoContentView = makeVideoContentView()

    private var configuration: VLCVideoPlayer.Configuration
    private var proxy: VLCVideoPlayer.Proxy?
    private let onTicksUpdated: (Int32, VLCVideoPlayer.PlaybackInformation) -> Void
    private let onStateUpdated: (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void
    private let loggingInfo: (logger: VLCVideoPlayerLogger, level: VLCVideoPlayer.LoggingLevel)?
    private var currentMediaPlayer: VLCMediaPlayer?

    private var hasSetCurrentConfigurationValues: Bool = false
    private var lastPlayerTicks: Int32 = 0
    private var lastPlayerState: VLCMediaPlayerState = .opening
    private var cancellables = Set<AnyCancellable>()

    private var aspectFillScale: CGFloat {
        guard let currentMediaPlayer = currentMediaPlayer else { return 1 }
        let videoSize = currentMediaPlayer.videoSize
        let fillSize = CGSize.aspectFill(aspectRatio: videoSize, minimumSize: videoContentView.bounds.size)
        return fillSize.scale(other: videoContentView.bounds.size)
    }

    init(
        configuration: VLCVideoPlayer.Configuration,
        proxy: VLCVideoPlayer.Proxy?,
        onTicksUpdated: @escaping (Int32, VLCVideoPlayer.PlaybackInformation) -> Void,
        onStateUpdated: @escaping (VLCVideoPlayer.State, VLCVideoPlayer.PlaybackInformation) -> Void,
        loggingInfo: (VLCVideoPlayerLogger, VLCVideoPlayer.LoggingLevel)?
    ) {
        self.configuration = configuration
        self.proxy = proxy
        self.onTicksUpdated = onTicksUpdated
        self.onStateUpdated = onStateUpdated
        self.loggingInfo = loggingInfo
        super.init(frame: .zero)

        proxy?.videoPlayerView = self

        #if os(macOS)
        layer?.backgroundColor = .clear
        #else
        backgroundColor = .clear
        #endif

        setupVideoContentView()
        setupVLCMediaPlayer(with: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVideoContentView() {
        addSubview(videoContentView)

        NSLayoutConstraint.activate([
            videoContentView.topAnchor.constraint(equalTo: topAnchor),
            videoContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            videoContentView.leftAnchor.constraint(equalTo: leftAnchor),
            videoContentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    func setupVLCMediaPlayer(with newConfiguration: VLCVideoPlayer.Configuration) {
        currentMediaPlayer?.stop()
        currentMediaPlayer = nil

        let media = VLCMedia(url: newConfiguration.url)
        media.addOptions(newConfiguration.options)

        let newMediaPlayer = VLCMediaPlayer()
        newMediaPlayer.media = media
        newMediaPlayer.drawable = videoContentView
        newMediaPlayer.delegate = self

        if let loggingInfo = loggingInfo {
            newMediaPlayer.libraryInstance.debugLogging = true
            newMediaPlayer.libraryInstance.debugLoggingLevel = loggingInfo.level.rawValue
            newMediaPlayer.libraryInstance.debugLoggingTarget = self
        }

        for child in newConfiguration.playbackChildren {
            newMediaPlayer.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
        }

        configuration = newConfiguration
        currentMediaPlayer = newMediaPlayer
        proxy?.mediaPlayer = newMediaPlayer
        hasSetCurrentConfigurationValues = false
        lastPlayerTicks = 0
        lastPlayerState = .opening

        if newConfiguration.autoPlay {
            newMediaPlayer.play()
        }
    }

    func setAspectFill(with percentage: Float) {
        guard percentage >= 0 && percentage <= 1 else { return }
        let scale = 1 + CGFloat(percentage) * (self.aspectFillScale - 1)
        self.videoContentView.scale(x: scale, y: scale)
    }

    private func makeVideoContentView() -> _PlatformView {
        let view = _PlatformView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        #if os(macOS)
        view.layer?.backgroundColor = .black
        #else
        view.backgroundColor = .black
        #endif
        return view
    }
}

// MARK: VLCMediaPlayerDelegate

extension UIVLCVideoPlayerView: VLCMediaPlayerDelegate {

    private func constructPlaybackInformation(player: VLCMediaPlayer, media: VLCMedia) -> VLCVideoPlayer.PlaybackInformation {

        let subtitleIndexes = player.videoSubTitlesIndexes as! [Int32]
        let subtitleNames = player.videoSubTitlesNames as! [String]

        let audioIndexes = player.audioTrackIndexes as! [Int32]
        let audioNames = player.audioTrackNames as! [String]

        let zippedSubtitleTracks = Dictionary(uniqueKeysWithValues: zip(subtitleIndexes, subtitleNames))
        let zippedAudioTracks = Dictionary(uniqueKeysWithValues: zip(audioIndexes, audioNames))

        let currentSubtitleTrack: MediaTrack
        let currentAudioTrack: MediaTrack

        if let currentValidSubtitleTrack = zippedSubtitleTracks[player.currentVideoSubTitleIndex] {
            currentSubtitleTrack = (player.currentVideoSubTitleIndex, currentValidSubtitleTrack)
        } else {
            currentSubtitleTrack = (index: -1, title: "Disable")
        }

        if let currentValidAudioTrack = zippedAudioTracks[player.currentAudioTrackIndex] {
            currentAudioTrack = (player.currentAudioTrackIndex, currentValidAudioTrack)
        } else {
            currentAudioTrack = (index: -1, title: "Disable")
        }

        return VLCVideoPlayer.PlaybackInformation(
            startConfiguration: configuration,
            position: player.position,
            length: media.length.intValue,
            isSeekable: player.isSeekable,
            playbackRate: player.rate,
            currentSubtitleTrack: currentSubtitleTrack,
            currentAudioTrack: currentAudioTrack,
            subtitleTracks: zippedSubtitleTracks,
            audioTracks: zippedAudioTracks,
            stats: media.stats ?? [:]
        )
    }

    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        let currentTicks = player.time.intValue
        let playbackInformation = constructPlaybackInformation(player: player, media: player.media!)

        onTicksUpdated(currentTicks, playbackInformation)

        // Set playing state
        if lastPlayerState != .playing,
           abs(currentTicks - lastPlayerTicks) >= 200
        {
            onStateUpdated(.playing, playbackInformation)
            lastPlayerState = .playing
            lastPlayerTicks = currentTicks

            if !hasSetCurrentConfigurationValues {
                setConfigurationValues(with: player, from: configuration)
                hasSetCurrentConfigurationValues = true
            }
        }

        // Replay
        if configuration.replay,
           lastPlayerState == .playing,
           abs(player.media!.length.intValue - currentTicks) <= 500
        {
            configuration.autoPlay = true
            configuration.startTime = .ticks(0)
            setupVLCMediaPlayer(with: configuration)
        }
    }

    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        guard player.state != .playing, player.state != lastPlayerState else { return }

        let wrappedState = VLCVideoPlayer.State(rawValue: player.state.rawValue) ?? .error
        let playbackInformation = constructPlaybackInformation(player: player, media: player.media!)

        onStateUpdated(wrappedState, playbackInformation)
        lastPlayerState = player.state
    }

    private func setConfigurationValues(with player: VLCMediaPlayer, from configuration: VLCVideoPlayer.Configuration) {

        player.time = VLCTime(int: configuration.startTime.asTicks)

        let defaultPlayerSpeed = player.rate(from: configuration.rate)
        player.fastForward(atRate: defaultPlayerSpeed)

        if configuration.aspectFill {
            videoContentView.scale(x: aspectFillScale, y: aspectFillScale)
        } else {
            videoContentView.apply(transform: .identity)
        }

        let defaultSubtitleTrackIndex = player.subtitleTrackIndex(from: configuration.subtitleIndex)
        player.currentVideoSubTitleIndex = defaultSubtitleTrackIndex

        let defaultAudioTrackIndex = player.audioTrackIndex(from: configuration.audioIndex)
        player.currentAudioTrackIndex = defaultAudioTrackIndex

        player.setSubtitleSize(configuration.subtitleSize)
        player.setSubtitleFont(configuration.subtitleFont)
        player.setSubtitleColor(configuration.subtitleColor)
    }
}

// MARK: VLCLibraryLogReceiverProtocol

extension UIVLCVideoPlayerView: VLCLibraryLogReceiverProtocol {

    public func handleMessage(_ message: String, debugLevel level: Int32) {
        guard let loggingInfo = loggingInfo,
              level >= loggingInfo.level.rawValue else { return }
        let level = VLCVideoPlayer.LoggingLevel(rawValue: level) ?? .info
        loggingInfo.logger.vlcVideoPlayer(didLog: message, at: level)
    }
}
