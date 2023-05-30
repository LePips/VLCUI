import SwiftUI
import VLCUI

struct ContentView: View {

    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                VLCVideoPlayer(configuration: viewModel.configuration)
                    .proxy(viewModel.proxy)
                    .onStateUpdated(viewModel.onStateUpdated)
                    .onTicksUpdated(viewModel.onTicksUpdated)
                
                VLCVideoPlayer(configuration: viewModel.configuration)
                    .proxy(viewModel.proxy)
//                    .onStateUpdated(viewModel.onStateUpdated)
//                    .onTicksUpdated(viewModel.onTicksUpdated)
            }
//            VLCVideoPlayer(configuration: viewModel.configuration)
//                .proxy(viewModel.proxy)
//                .onStateUpdated(viewModel.onStateUpdated)
//                .onTicksUpdated(viewModel.onTicksUpdated)

            OverlayView(viewModel: viewModel)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
