import Combine
import Foundation
import MediaPlayer
import UIKit

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

// TODO: Cleanup constructPlaybackInformation

public class UIVLCVideoPlayerViewController: UIViewController {

    private lazy var videoContentView = makeVideoContentView()

    private var currentConfiguration: VLCVideoPlayer.Configuration
    private let delegate: VLCVideoPlayerDelegate
    private var currentMediaPlayer: VLCMediaPlayer?

    private var hasSetDefaultConfiguration: Bool = false
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
        delegate: VLCVideoPlayerDelegate
    ) {
        self.currentConfiguration = configuration
        self.delegate = delegate
        self.currentMediaPlayer = nil
        super.init(nibName: nil, bundle: nil)

        setupVLCMediaPlayer(with: configuration)
        setupEventSubjectListener()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupVideoContentView()

        view.backgroundColor = .clear
        view.accessibilityIgnoresInvertColors = true
    }

    private func setupVideoContentView() {
        view.addSubview(videoContentView)

        NSLayoutConstraint.activate([
            videoContentView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoContentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoContentView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }

    private func setupVLCMediaPlayer(with configuration: VLCVideoPlayer.Configuration) {
        self.currentMediaPlayer?.stop()
        self.currentMediaPlayer = nil

        let media = VLCMedia(url: configuration.url)
        media.addOptions(configuration.options)

        let newMediaPlayer = VLCMediaPlayer()
        newMediaPlayer.media = media
        newMediaPlayer.drawable = videoContentView
        newMediaPlayer.delegate = self

        for child in configuration.playbackChildren {
            newMediaPlayer.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
        }

        self.currentConfiguration = configuration
        self.currentMediaPlayer = newMediaPlayer
        self.hasSetDefaultConfiguration = false
        self.lastPlayerTicks = 0
        self.lastPlayerState = .opening

        if configuration.autoPlay {
            newMediaPlayer.play()
        }
    }

    private func makeVideoContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }
}

// MARK: Event Listener

public extension UIVLCVideoPlayerViewController {

    func setupEventSubjectListener() {
        delegate.eventSubject.sink { event in
            guard let event = event,
                  let currentMediaPlayer = self.currentMediaPlayer,
                  let media = currentMediaPlayer.media else { return }
            switch event {
            case .play:
                currentMediaPlayer.play()
            case .pause:
                currentMediaPlayer.pause()
            case .stop:
                currentMediaPlayer.stop()
            case .cancel:
                currentMediaPlayer.stop()
                self.cancellables.forEach { $0.cancel() }
            case let .jumpForward(interval):
                currentMediaPlayer.jumpForward(interval)
            case let .jumpBackward(interval):
                currentMediaPlayer.jumpBackward(interval)
            case .gotoNextFrame:
                currentMediaPlayer.gotoNextFrame()
            case let .setSubtitleTrack(track):
                let newTrackIndex = currentMediaPlayer.subtitleTrackIndex(from: track)
                currentMediaPlayer.currentVideoSubTitleIndex = newTrackIndex
            case let .setAudioTrack(track):
                let newTrackIndex = currentMediaPlayer.audioTrackIndex(from: track)
                currentMediaPlayer.currentAudioTrackIndex = newTrackIndex
            case let .setSubtitleDelay(delay):
                let delay = Int(delay.asTicks) * 1000
                currentMediaPlayer.currentVideoSubTitleDelay = delay
            case let .setAudioDelay(delay):
                let delay = Int(delay.asTicks) * 1000
                currentMediaPlayer.currentAudioPlaybackDelay = delay
            case let .fastForward(speed):
                let newSpeed = currentMediaPlayer.fastForwardSpeed(from: speed)
                currentMediaPlayer.fastForward(atRate: newSpeed)
            case let .aspectFill(fill):
                guard fill >= 0 && fill <= 1 else { return }
                let scale = 1 + CGFloat(fill) * (self.aspectFillScale - 1)
                self.videoContentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            case let .setTime(time):
                guard time.asTicks >= 0 && time.asTicks <= media.length.intValue else { return }
                currentMediaPlayer.time = VLCTime(int: time.asTicks)
            case let .setSubtitleSize(size):
                currentMediaPlayer.setSubtitleSize(size)
            case let .setSubtitleFont(font):
                currentMediaPlayer.setSubtitleFont(font)
            case let .setSubtitleColor(color):
                currentMediaPlayer.setSubtitleColor(color)
            case let .addPlaybackChild(child):
                currentMediaPlayer.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
            case let .playNewMedia(newConfiguration):
                self.setupVLCMediaPlayer(with: newConfiguration)
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: VLCMediaPlayerDelegate

extension UIVLCVideoPlayerViewController: VLCMediaPlayerDelegate {

    private func constructPlaybackInformation(player: VLCMediaPlayer, media: VLCMedia) -> VLCVideoPlayer.PlaybackInformation {

        let subtitleIndexes = player.videoSubTitlesIndexes as! [Int32]
        let subtitleNames = player.videoSubTitlesNames as! [String]

        let audioIndexes = player.audioTrackIndexes as! [Int32]
        let audioNames = player.audioTrackNames as! [String]

        let zippedSubtitleTracks = Dictionary(uniqueKeysWithValues: zip(subtitleIndexes, subtitleNames))
        let zippedAudioTracks = Dictionary(uniqueKeysWithValues: zip(audioIndexes, audioNames))

        let currentSubtitleTrack: (Int32, String)
        let currentAudioTrack: (Int32, String)

        if let currentValidSubtitleTrack = zippedSubtitleTracks[player.currentVideoSubTitleIndex] {
            currentSubtitleTrack = (player.currentVideoSubTitleIndex, currentValidSubtitleTrack)
        } else {
            currentSubtitleTrack = (-1, "Disable")
        }

        if let currentValidAudioTrack = zippedAudioTracks[player.currentAudioTrackIndex] {
            currentAudioTrack = (player.currentAudioTrackIndex, currentValidAudioTrack)
        } else {
            currentAudioTrack = (-1, "Disable")
        }

        return VLCVideoPlayer.PlaybackInformation(
            currentConfiguration: currentConfiguration,
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

        delegate.vlcVideoPlayer(
            didUpdateTicks: currentTicks,
            with: playbackInformation
        )

        if lastPlayerState != .playing && abs(currentTicks - lastPlayerTicks) >= 200 {
            delegate.vlcVideoPlayer(didUpdateState: .playing, with: playbackInformation)
            lastPlayerState = .playing
            lastPlayerTicks = currentTicks

            if !hasSetDefaultConfiguration {
                setDefaultConfiguration(with: player, from: currentConfiguration)
                hasSetDefaultConfiguration = true
            }
        }
    }

    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        guard player.state != .playing, player.state != lastPlayerState else { return }

        let wrappedState = VLCVideoPlayer.State(rawValue: player.state.rawValue) ?? .error
        let playbackInformation = constructPlaybackInformation(player: player, media: player.media!)

        delegate.vlcVideoPlayer(didUpdateState: wrappedState, with: playbackInformation)
        lastPlayerState = player.state
    }

    private func setDefaultConfiguration(with player: VLCMediaPlayer, from configuration: VLCVideoPlayer.Configuration) {

        player.time = VLCTime(int: configuration.startTime.asTicks)

        let defaultPlayerSpeed = player.fastForwardSpeed(from: configuration.playbackSpeed)
        player.fastForward(atRate: defaultPlayerSpeed)

        if configuration.aspectFill {
            self.videoContentView.transform = CGAffineTransform(scaleX: aspectFillScale, y: aspectFillScale)
        } else {
            self.videoContentView.transform = .identity
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
