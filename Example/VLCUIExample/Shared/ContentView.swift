import SwiftUI
import VLCUI

struct ContentView: View {

    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VLCVideoPlayer(configuration: viewModel.configuration)
                .eventSubject(viewModel.eventSubject)
                .onTicksUpdated { ticks, playbackInformation in
                    viewModel.ticks = ticks
                    viewModel.totalTicks = playbackInformation.length
                    viewModel.position = playbackInformation.position
                }
                .onStateUpdated { state, _ in
                    viewModel.playerState = state
                }

            OverlayView(viewModel: viewModel)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
