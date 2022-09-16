import SwiftUI
import VLCUI

struct OverlayView: View {

    @ObservedObject
    var viewModel: ContentViewModel

    func timeText(for ticks: Int32) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: TimeInterval(Int(ticks))) ?? "--:--"
    }

    var body: some View {
        HStack {
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
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                }
                .font(.system(size: 28, weight: .heavy, design: .default))
            }

            Button {
                viewModel.eventSubject.send(.jumpForward(15))
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 28, weight: .regular, design: .default))
            }

            Text(timeText(for: viewModel.ticks / 1000))
                .frame(width: 100)
        }
    }
}
