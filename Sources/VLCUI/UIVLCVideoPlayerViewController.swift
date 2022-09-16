import Combine
import Foundation
import MediaPlayer
import UIKit

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

public class UIVLCVideoPlayerViewController: UIViewController {

    private lazy var videoContentView = makeVideoContentView()

    private let playbackURL: URL
    private let configuration: VLCVideoPlayer.Configuration
    private let delegate: VLCVideoPlayerDelegate?

    private var lastPlayerTicks: Int32 = 0
    private var lastPlayerState: VLCMediaPlayerState = .opening

    private var mediaPlayer: VLCMediaPlayer!
    private var cancellables = Set<AnyCancellable>()

    init(
        url: URL,
        configuration: VLCVideoPlayer.Configuration,
        delegate: VLCVideoPlayerDelegate?
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

    // TODO: Cleanup
    func setupEventSubjectListener() {
        guard let delegate = delegate else { return }
        delegate.eventSubject.sink { event in
            guard let event = event else { return }
            switch event {
            case .play:
                self.mediaPlayer.play()
            case .pause:
                self.mediaPlayer.pause()
            case .stop:
                self.mediaPlayer.stop()
            case let .jumpForward(interval):
                self.mediaPlayer.jumpForward(interval)
            case let .jumpBackward(interval):
                self.mediaPlayer.jumpBackward(interval)
            case let .setSubtitleIndex(track):
                switch track {
                case .auto:
                    if let indexes = self.mediaPlayer.videoSubTitlesIndexes as? [Int32], let first = indexes.first(where: { $0 != -1 }) {
                        self.mediaPlayer.currentVideoSubTitleIndex = first
                        delegate.subtitleIndexDidChange(first)
                    }
                case let .absolute(index):
                    self.mediaPlayer.currentVideoSubTitleIndex = index
                    delegate.subtitleIndexDidChange(index)
                }
            case let .setAudioIndex(track):
                switch track {
                case .auto:
                    if let indexes = self.mediaPlayer.audioTrackIndexes as? [Int32], let first = indexes.first(where: { $0 != -1 }) {
                        self.mediaPlayer.currentAudioTrackIndex = first
                        delegate.audioIndexDidChange(first)
                    }
                case let .absolute(index):
                    self.mediaPlayer.currentAudioTrackIndex = index
                }
            case let .setPlaybackSpeed(speed):
                self.mediaPlayer.rate = speed
            case let .aspectFill(fill):
                if fill {
                    self.fillScreen(screenSize: self.videoContentView.bounds.size)
                } else {
                    self.shrinkScreen()
                }
            case let .setPosition(position):
                assert(position >= 0 && position <= 1, "Position must be in the range 0...1")
                self.mediaPlayer.position = position
            case let .setSubtitleSize(size):
                self.mediaPlayer.setSubtitleSize(size)
            case let .setSubtitleFont(fontName):
                self.mediaPlayer.setSubtitleFont(fontName)
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
    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        guard let delegate = delegate else { return }
        let player = aNotification.object as! VLCMediaPlayer
        let ticks = player.time.intValue

        delegate.ticksUpdated(ticks, player.position)

        if lastPlayerState != .playing && abs(ticks - lastPlayerTicks) >= 200 {
            delegate.playerStateUpdated(.playing)
            lastPlayerState = .playing
            lastPlayerTicks = ticks
        }
    }

    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let delegate = delegate else { return }
        let player = aNotification.object as! VLCMediaPlayer
        guard player.state != .playing else { return }

        let wrappedState = VLCVideoPlayer.State(rawValue: player.state.rawValue) ?? .error

        delegate.playerStateUpdated(wrappedState)
        lastPlayerState = player.state

        if wrappedState == .esAdded {
            switch configuration.defaultSubtitleIndex {
            case .auto: ()
            case let .absolute(index):
                player.currentVideoSubTitleIndex = index
            }

            switch configuration.defaultAudioIndex {
            case .auto: ()
            case let .absolute(index):
                player.currentAudioTrackIndex = index
            }

            let subtitleIndexes = player.videoSubTitlesIndexes as! [Int32]
            let subtitleNames = player.videoSubTitlesNames as! [String]

            let audioIndexes = player.audioTrackIndexes as! [Int32]
            let audioNames = player.audioTrackNames as! [String]

            let zippedSubtitles = Array(zip(subtitleIndexes, subtitleNames))
            let zippedAudios = Array(zip(audioIndexes, audioNames))

            delegate.didParseSubtitleIndexes(zippedSubtitles)
            delegate.didParseAudioIndexes(zippedAudios)
            delegate.subtitleIndexDidChange(player.currentVideoSubTitleIndex)
            delegate.audioIndexDidChange(player.currentAudioTrackIndex)
        }
    }
}
