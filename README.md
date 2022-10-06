# VLCUI

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

An example project is provided to show basic functionality of VLCUI. Download the frameworks with the provided **Cartfile**:

```shell
carthage update --use-xcframeworks
```