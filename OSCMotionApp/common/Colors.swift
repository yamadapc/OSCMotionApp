//
//  Colors.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation

#if os(macOS)
  import AppKit

  struct AppColors {
    static let black = NSColor.black
    static let white = NSColor.white
    static let gray = NSColor.gray
    static let orange = NSColor.orange
    static let purple = NSColor.purple
  }
#else
  import UIKit

  struct AppColors {
    static let black = UIColor.black
    static let white = UIColor.white
    static let gray = UIColor.gray
    static let orange = UIColor.orange
    static let purple = UIColor.purple
  }
#endif
