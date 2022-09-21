import SwiftUI
import VLCUI

struct ContentView: View {

    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VLCVideoPlayer(configuration: viewModel.configuration)
                    .delegate(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }

            OverlayView(viewModel: viewModel)
                .padding()
        }
    }
}
