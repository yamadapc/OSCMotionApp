//
//  Colors.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation

#if os(macOS)
  import AppKit

  typealias AppColor = NSColor
#else
  import UIKit

  typealias AppColor = UIColor
#endif
