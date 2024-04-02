//
//  MessageConfiguration.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import MIDIKit

class MIDIMessageConfiguration: ObservableObject {
  @Published var midiChannel: Int
  @Published var midiCC: MIDIEvent.CC.Controller
  @Published var midiRange: (Int, Int)

  init() {
    midiChannel = 1
    midiCC = .generalPurpose1
    midiRange = (0, 127)
  }
}

class OSCMessageConfiguration: ObservableObject {
  init() {}
}

class MessageConfiguration: ObservableObject, Identifiable {
  @Published var id: String
  @Published var midiConfiguration = MIDIMessageConfiguration()

  init(id: String) {
    self.id = id
  }
}
