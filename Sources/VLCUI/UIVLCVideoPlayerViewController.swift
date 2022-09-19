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

    private let playbackURL: URL
    private let configuration: VLCVideoPlayer.Configuration
    private let delegate: VLCVideoPlayerDelegate

    private var hasSetDefaultConfiguration: Bool = false
    private var lastPlayerTicks: Int32 = 0
    private var lastPlayerState: VLCMediaPlayerState = .opening

    private var mediaPlayer: VLCMediaPlayer!
    private var cancellables = Set<AnyCancellable>()

    init(
        url: URL,
        configuration: VLCVideoPlayer.Configuration,
        delegate: VLCVideoPlayerDelegate
    ) {
        self.playbackURL = url
        self.configuration = configuration
        self.delegate = delegate
        self.mediaPlayer = nil
        super.init(nibName: nil, bundle: nil)

        setupVLCMediaPlayer()
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

    private func setupVLCMediaPlayer() {
        let media = VLCMedia(url: playbackURL)
        media.addOptions(configuration.options)

        let vlcMediaPlayer = VLCMediaPlayer()
        vlcMediaPlayer.media = media
        vlcMediaPlayer.drawable = videoContentView
        vlcMediaPlayer.delegate = self

        for child in configuration.playbackChildren {
            vlcMediaPlayer.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
        }

        self.mediaPlayer = vlcMediaPlayer

        if configuration.autoPlay {
            vlcMediaPlayer.play()
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
        guard let media = mediaPlayer.media else { return }

        delegate.eventSubject.sink { event in
            guard let event = event else { return }
            switch event {
            case .play:
                self.mediaPlayer.play()
            case .pause:
                self.mediaPlayer.pause()
            case .stop:
                self.mediaPlayer.stop()
                self.cancellables.forEach { $0.cancel() }
            case let .jumpForward(interval):
                self.mediaPlayer.jumpForward(interval)
            case let .jumpBackward(interval):
                self.mediaPlayer.jumpBackward(interval)
            case let .setSubtitleTrack(track):
                let newTrackIndex = self.mediaPlayer.subtitleTrackIndex(from: track)
                self.mediaPlayer.currentVideoSubTitleIndex = newTrackIndex
            case let .setAudioTrack(track):
                let newTrackIndex = self.mediaPlayer.audioTrackIndex(from: track)
                self.mediaPlayer.currentAudioTrackIndex = newTrackIndex
            case let .fastForward(speed):
                let newSpeed = self.mediaPlayer.fastForwardSpeed(from: speed)
                self.mediaPlayer.fastForward(atRate: newSpeed)
            case let .aspectFill(fill):
                if fill {
                    self.fillScreen(screenSize: self.videoContentView.bounds.size)
                } else {
                    self.shrinkScreen()
                }
            case let .setTime(time):
                assert(time.asTicks >= 0 && time.asTicks <= media.length.intValue, "Given time not in range of media length")
                self.mediaPlayer.time = VLCTime(int: time.asTicks)
            case let .setSubtitleSize(size):
                self.mediaPlayer.setSubtitleSize(size)
            case let .setSubtitleFont(font):
                self.mediaPlayer.setSubtitleFont(font)
            case let .setSubtitleColor(color):
                self.mediaPlayer.setSubtitleColor(color)
            case let .addPlaybackChild(child):
                self.mediaPlayer.addPlaybackSlave(child.url, type: child.type.asVLCSlaveType, enforce: child.enforce)
            }
        }
        .store(in: &cancellables)
    }

    private func fillScreen(screenSize: CGSize) {
        let videoSize = mediaPlayer.videoSize
        let fillSize = CGSize.aspectFill(aspectRatio: videoSize, minimumSize: screenSize)

        let scale: CGFloat

        if fillSize.height > screenSize.height {
            scale = fillSize.height / screenSize.height
        } else {
            scale = fillSize.width / screenSize.width
        }

        UIView.animate(withDuration: 0.2) {
            self.videoContentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    private func shrinkScreen() {
        UIView.animate(withDuration: 0.2) {
            self.videoContentView.transform = .identity
        }
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
            delegate.vlcVideoPlayer(didUpdateState: .playing)
            lastPlayerState = .playing
            lastPlayerTicks = currentTicks

            if !hasSetDefaultConfiguration {
                setDefaultConfiguration(with: player)
                hasSetDefaultConfiguration = true
            }
        }
    }

    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        guard player.state != .playing, player.state != lastPlayerState else { return }

        let wrappedState = VLCVideoPlayer.State(rawValue: player.state.rawValue) ?? .error

        delegate.vlcVideoPlayer(didUpdateState: wrappedState)
        lastPlayerState = player.state
    }

    private func setDefaultConfiguration(with player: VLCMediaPlayer) {
        let defaultSubtitleTrackIndex = player.subtitleTrackIndex(from: configuration.subtitleIndex)
        player.currentVideoSubTitleIndex = defaultSubtitleTrackIndex

        let defaultAudioTrackIndex = player.audioTrackIndex(from: configuration.audioIndex)
        player.currentAudioTrackIndex = defaultAudioTrackIndex

        player.setSubtitleSize(configuration.subtitleSize)
        player.setSubtitleFont(configuration.subtitleFont)
        player.setSubtitleColor(configuration.subtitleColor)

        player.time = VLCTime(int: configuration.startTime.asTicks)

        let defaultPlayerSpeed = player.fastForwardSpeed(from: configuration.playbackSpeed)
        player.fastForward(atRate: defaultPlayerSpeed)
    }
}
