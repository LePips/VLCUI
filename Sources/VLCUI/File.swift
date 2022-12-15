//
//  File.swift
//  
//
//  Created by Ethan Pippin on 12/14/22.
//

import SwiftUI

public struct TestViewController: UIViewControllerRepresentable {
    
    let configuration: VLCVideoPlayer.Configuration
    let proxy: VLCVideoPlayer.Proxy
    
    public init(configuration: VLCVideoPlayer.Configuration, proxy: VLCVideoPlayer.Proxy) {
        self.configuration = configuration
        self.proxy = proxy
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        UITestViewController(configuration: configuration, proxy: proxy)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}


public class UITestViewController: UIViewController, AVPIPUIKitUsable {
    
    let configuration: VLCVideoPlayer.Configuration
    let proxy: VLCVideoPlayer.Proxy
    
    init(configuration: VLCVideoPlayer.Configuration, proxy: VLCVideoPlayer.Proxy) {
        self.configuration = configuration
        self.proxy = proxy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let vlcView = UIVLCVideoPlayerView(
            configuration: configuration,
            proxy: proxy,
            onTicksUpdated: { _, _ in },
            onStateUpdated: { _, _ in },
            loggingInfo: nil
        )
        
        view.addSubview(vlcView)
        vlcView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vlcView.topAnchor.constraint(equalTo: view.topAnchor),
            vlcView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vlcView.leftAnchor.constraint(equalTo: view.leftAnchor),
            vlcView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        if #available(iOS 15, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.testPIP()
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func testPIP() {
        self.startPictureInPicture()
    }
}
