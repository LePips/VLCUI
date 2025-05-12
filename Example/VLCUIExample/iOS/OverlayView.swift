import SwiftUI
import VLCUI

struct OverlayView: View {

    @ObservedObject
    var viewModel: ContentViewModel
    @State
    var isScrubbing: Bool = false
    @State
    var currentPosition: Float = 0

    @ViewBuilder
    var recordButton: some View {
        Image(systemName: "record.circle")
            .font(.system(size: 28, weight: .regular, design: .default))
            .foregroundColor(viewModel.isRecording ? .red : .accentColor)
    }
    
    var body: some View {
        HStack(spacing: 20) {

            
            Button(action: {
                if viewModel.isRecording {
                    viewModel.proxy.stopRecording()
                    viewModel.isRecording.toggle()
                } else {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let isRecording = viewModel.proxy.startRecording(directoryPath: documentsPath.path)
                    print("Recording Path:", documentsPath.path)
                    viewModel.isRecording = isRecording
                }
            }) {
                if #available(iOS 17.0, *) {
                     recordButton
                        .symbolEffect(.pulse, isActive: viewModel.isRecording)
                } else {
                    recordButton
                }
            }
            
            Group {
                Button {
                    viewModel.proxy.jumpBackward(15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 28, weight: .regular, design: .default))
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
                    .font(.system(size: 28, weight: .heavy, design: .default))
                    .frame(maxWidth: 30)
                }

                Button {
                    viewModel.proxy.jumpForward(15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 28, weight: .regular, design: .default))
                }
                
                HStack(spacing: 5) {
                    Text(viewModel.positiveTimeLabel)
                        .frame(width: 50)

                    Slider(
                        value: $currentPosition,
                        in: 0 ... Float(1.0)
                    ) { isEditing in
                        isScrubbing = isEditing
                    }

                    Text(viewModel.negativeTimeLabel)
                        .frame(width: 50)
                }
            }.disabled(viewModel.isRecording)
            
        }
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
