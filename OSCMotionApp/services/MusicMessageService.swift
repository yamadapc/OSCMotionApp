//
//  MusicMessageService.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import MIDIKit
import OSCKit
import OSCKit

class MusicMessageService {
  private let midiManager = MIDIManager(
    clientName: "OSCMotionAppMIDIManager",
    model: "OSCMotionApp",
    manufacturer: "Beijaflor"
  )

  private let oscManager = OSCClient()

  init() {
  }

  func start() throws {
    try midiManager.start()
  }
}
