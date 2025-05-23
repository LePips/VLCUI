import SwiftUI

#if os(macOS)
import AppKit

public typealias _PlatformView = NSView
public typealias _PlatformRepresentable = NSViewRepresentable
public typealias _PlatformColor = NSColor
public typealias _PlatformFont = NSFont
public typealias _PlatformImage = NSImage
#else
import UIKit

public typealias _PlatformView = UIView
public typealias _PlatformRepresentable = UIViewRepresentable
public typealias _PlatformColor = UIColor
public typealias _PlatformFont = UIFont
public typealias _PlatformImage = UIImage
#endif
