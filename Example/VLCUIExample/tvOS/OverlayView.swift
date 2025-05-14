import SwiftUI
import VLCUI

struct OverlayView: View {

    @ObservedObject
    var viewModel: ContentViewModel
    @State
    private var isScrubbing: Bool = false
    @State
    private var currentPosition: Float = 0
    
    var body: some View {
        HStack(spacing: 20) {
            
            HStack(spacing: 5) {
                Text(viewModel.positiveSeconds, format: .runtime)
                    .frame(width: 50)

                Capsule()
                    .frame(width: 10, height: 2)

                Text(viewModel.negativeSeconds, format: .runtime)
                    .frame(width: 50)
            }
            .font(.system(size: 18, weight: .regular, design: .default))
            .monospacedDigit()
            
            Button("Go backward", systemImage: "gobackward.15") {
                viewModel.proxy.jumpBackward(seconds: 15)
            }

            Button {
                if viewModel.playerState == .playing {
                    viewModel.proxy.pause()
                } else {
                    viewModel.proxy.play()
                }
            } label: {
                Group {
                    if viewModel.playerState == .playing {
                        Image(systemName: "pause.circle.fill")
                    } else if viewModel.playerState == .buffering {
                        ProgressView()
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                }
                .frame(maxWidth: 30)
            }

            Button("Go forward", systemImage: "goforward.15") {
                viewModel.proxy.jumpForward(seconds: 15)
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .font(.system(size: 28, weight: .regular, design: .default))
        .onChange(of: isScrubbing) {
            guard !isScrubbing else { return }
            viewModel.proxy.setTime(.ticks(viewModel.totalTicks * Int(currentPosition * 100) / 100))
        }
        .onChange(of: viewModel.position) {
            guard !isScrubbing else { return }
            currentPosition = viewModel.position
        }
    }
}
