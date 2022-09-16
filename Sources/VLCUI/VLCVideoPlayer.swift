import Combine
import Foundation
import MediaPlayer
import SwiftUI

#if os(tvOS)
import TVVLCKit
#else
import MobileVLCKit
#endif

protocol VLCVideoPlayerDelegate {
    var eventSubject: CurrentValueSubject<VLCVideoPlayer.Event?, Never> { get set }
    
    func ticksUpdated(_ ticks: Int32)
    func playerStateUpdated(_ newState: VLCVideoPlayer.State)
}

struct VLCVideoPlayer: UIViewControllerRepresentable {
    
    // Configuration for VLCMediaPlayer
    struct Configuration {
        var options: [String: Any]
        
    }
    
    // Possible events to send to the underlying VLC media player
    enum Event {
        case pause
        case play
        case jumpForward(Int32)
        case jumpBackward(Int32)
    }
    
    // Wrapper of VLCMediaPlayerState so that MediaPlayer and MobileVLCKit/TVVLCKit
    // are not necessary to be imported where VLCVideoPlayer is used
    enum State: Int {
        case stopped
        case opening
        case buffering
        case ended
        case error
        case playing
        case paused
        case esAdded
    }
    
    private let url: URL
    private let delegate: VLCVideoPlayerDelegate
    
    init(url: URL, delegate: VLCVideoPlayerDelegate) {
        self.url = url
        self.delegate = delegate
    }
    
    func makeUIViewController(context: Context) -> UIVLCVideoPlayerViewController {
        UIVLCVideoPlayerViewController.init(url: url, delegate: delegate)
    }
    
    func updateUIViewController(_ uiViewController: UIVLCVideoPlayerViewController, context: Context) { }
}

class UIVLCVideoPlayerViewController: UIViewController {
    
    private lazy var videoContentView = makeVideoContentView()
    
    private let playbackURL: URL
    private let delegate: VLCVideoPlayerDelegate
    
    private var lastPlayerTicks: Int32 = 0
    private var lastPlayerState: VLCMediaPlayerState = .opening
    
    private var mediaPlayer: VLCMediaPlayer!
    private var cancellables = Set<AnyCancellable>()
    
    init(url: URL, delegate: VLCVideoPlayerDelegate) {
        self.playbackURL = url
        self.delegate = delegate
        self.mediaPlayer = nil
        super.init(nibName: nil, bundle: nil)
        
        setupVLCMediaPlayer()
        setupEventSubjectListener()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
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
            videoContentView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setupVLCMediaPlayer() {
        let media = VLCMedia(url: playbackURL)
        
        media.addOption("--prefetch-buffer-size=1048576")
        media.addOption("--network-caching=5000")
        
        let vlcMediaPlayer = VLCMediaPlayer()
        vlcMediaPlayer.media = media
        vlcMediaPlayer.drawable = videoContentView
        vlcMediaPlayer.delegate = self
        
        self.mediaPlayer = vlcMediaPlayer
    }
    
    private func makeVideoContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }
}

// MARK: Event Listener

extension UIVLCVideoPlayerViewController {
    func setupEventSubjectListener() {
        delegate.eventSubject.sink { event in
            guard let event = event else { return }
            switch event {
            case .play:
                self.mediaPlayer.play()
            case .pause:
                self.mediaPlayer.pause()
            case .jumpForward(let interval):
                self.mediaPlayer.jumpForward(interval)
            case .jumpBackward(let interval):
                self.mediaPlayer.jumpBackward(interval)
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: VLCMediaPlayerDelegate

extension UIVLCVideoPlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        let ticks = player.time.intValue

        delegate.ticksUpdated(ticks)
        
        if lastPlayerState != .playing && abs(ticks - lastPlayerTicks) >= 200 {
            delegate.playerStateUpdated(.playing)
            lastPlayerState = .playing
            lastPlayerTicks = ticks
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        let player = aNotification.object as! VLCMediaPlayer
        guard player.state != .playing else { return }
        delegate.playerStateUpdated(VLCVideoPlayer.State(rawValue: player.state.rawValue) ?? .error)
        lastPlayerState = player.state
    }
}
