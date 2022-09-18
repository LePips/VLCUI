import SwiftUI
import VLCUI

struct OverlayView: View {

    @ObservedObject
    var viewModel: ContentViewModel
    @State
    var isScrubbing: Bool = false
    @State
    var currentPosition: Float = 0

    func timeText(for ticks: Int32) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: TimeInterval(Int(ticks))) ?? "--:--"
    }

    var body: some View {
        HStack(spacing: 20) {

            Button {
                viewModel.eventSubject.send(.jumpBackward(15))
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 28, weight: .regular, design: .default))
            }

            Button {
                if viewModel.playerState == .playing {
                    viewModel.eventSubject.send(.pause)
                } else {
                    viewModel.eventSubject.send(.play)
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
                viewModel.eventSubject.send(.jumpForward(15))
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 28, weight: .regular, design: .default))
            }

            HStack(spacing: 5) {
                Text(timeText(for: viewModel.ticks.roundNearestThousand / 1000))
                    .frame(width: 50)

                Slider(
                    value: $currentPosition,
                    in: 0 ... Float(1.0)
                ) { isEditing in
                    isScrubbing = isEditing
                }

                Text(timeText(for: (viewModel.totalTicks.roundNearestThousand - viewModel.ticks.roundNearestThousand) / 1000))
                    .frame(width: 50)
            }
        }
        .onChange(of: isScrubbing) { isScrubbing in
            guard !isScrubbing else { return }
            self.viewModel.eventSubject.send(.setTicks(viewModel.totalTicks * Int32(currentPosition * 100) / 100))
        }
        .onChange(of: viewModel.position) { newValue in
            guard !isScrubbing else { return }
            self.currentPosition = newValue
        }
    }
}
