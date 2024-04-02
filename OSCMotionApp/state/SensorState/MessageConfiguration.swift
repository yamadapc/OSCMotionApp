//
//  MessageConfiguration.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import MIDIKit

class MIDIMessageConfiguration: Codable {
  var midiChannel: Int
  var midiCC: Int
  var midiRangeStart: Int
  var midiRangeEnd: Int

  init() {
    midiChannel = 1
    midiCC = MIDIEvent.CC.Controller.generalPurpose1.number.intValue
    midiRangeStart = 0
    midiRangeEnd = 127
  }
}

class OSCMessageConfiguration: Codable {
  init() {}
}

class MessageConfiguration: Identifiable, Codable {
  var id: String
  var midiConfiguration = MIDIMessageConfiguration()

  init(id: String) {
    self.id = id
  }
}
