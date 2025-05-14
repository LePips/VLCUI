import SwiftUI
import VLCUI

struct OverlayView: View {

    @ObservedObject
    var viewModel: ContentViewModel
    @State
    var isScrubbing: Bool = false
    @State
    var currentPosition: Float = 0
    
    private var positiveSeconds: Int {
        viewModel.ticks.roundDownNearestThousand / 1000
    }
    
    private var negativeSeconds: Int {
        (viewModel.totalTicks.roundDownNearestThousand - viewModel.ticks.roundDownNearestThousand) / 1000
    }
    
    var body: some View {
        HStack(spacing: 20) {

            Button("Record", systemImage: "record.circle") {
                if viewModel.isRecording {
                    viewModel.proxy.stopRecording()
                    viewModel.isRecording = false
                } else {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    print("Recording Path:", documentsPath.path)
                    viewModel.proxy.startRecording(atPath: documentsPath.path)
                    viewModel.isRecording = true
                }
            }
            .foregroundStyle(viewModel.isRecording ? .red : .accentColor)
//            .symbolEffect(.pulse, value: viewModel.isRecording)
            
            Button("Go backward", systemImage: "gobackward.15") {
                viewModel.proxy.jumpBackward(15)
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
                viewModel.proxy.jumpForward(15)
            }
            
            HStack(spacing: 5) {
                Text(positiveSeconds, format: .runtime)
                    .frame(width: 50)
                
                Text(123, format: .number)

                Slider(
                    value: $currentPosition,
                    in: 0 ... Float(1.0)
                ) { isEditing in
                    isScrubbing = isEditing
                }

                Text(negativeSeconds, format: .runtime)
                    .frame(width: 50)
            }
            .font(.system(size: 18, weight: .regular, design: .default))
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 28, weight: .regular, design: .default))
        .onChange(of: isScrubbing) { isScrubbing in
            guard !isScrubbing else { return }
            viewModel.proxy.setTime(.ticks(viewModel.totalTicks * Int(currentPosition * 100) / 100))
        }
        .onChange(of: viewModel.position) { newValue in
            guard !isScrubbing else { return }
            currentPosition = newValue
        }
    }
}

#Preview {
    OverlayView(viewModel: .init())
}
