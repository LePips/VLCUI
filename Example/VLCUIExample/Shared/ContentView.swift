import SwiftUI
import VLCUI

struct ContentView: View {

    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VLCVideoPlayer(configuration: viewModel.configuration)
                .proxy(viewModel.proxy)
                .onStateUpdated(viewModel.onStateUpdated)
                .onSecondsUpdated(viewModel.onSecondsUpdated)

            OverlayView(viewModel: viewModel)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
