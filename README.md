A [VLCKit](https://code.videolan.org/videolan/VLCKit) wrapper for SwiftUI.

## Requirements

VLCKit must be installed and added to your project prior to using VLCUI.

## Usage

```swift
struct ContentView: View {
	var body: some View {
		VLCVideoPlayer(url: /* video url */)
	}
}
```

## Example

An example project for iOS and tvOS is provided to show basic functionality of VLCUI. In order to start the example project, you must download and link the frameworks.

An example **Cartfile** is provided. Run the following command to download the frameworks:
```
carthage update --use-xcframeworks
```