//
//  ConfigurationState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import SwiftPrettyPrint
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: String(describing: ConfigurationState.self)
)

struct MIDIMessageConfiguration: Codable {
  var midiCC: Int
  var midiRangeStart: Int?
  var midiRangeEnd: Int?

  init(midiCC: Int, midiRangeStart: Int? = nil, midiRangeEnd: Int? = nil) {
    self.midiCC = midiCC
    self.midiRangeStart = midiRangeStart
    self.midiRangeEnd = midiRangeEnd
  }
}

struct OSCMessageConfiguration {

}

struct MessageConfiguration {
  let midi: MIDIMessageConfiguration
  let osc: OSCMessageConfiguration
}

struct SensorMIDIConfiguration: Codable {
  let midiChannel: Int
}

struct SensorConfiguration: Decodable {
  let id: String
  let midiConfiguration: SensorMIDIConfiguration
}

struct ConfigurationState: Decodable {
  let oscServerConfiguration: OSCServerConfiguration
  let sensors: [SensorConfiguration]

  static func loadFromFile(url: URL) -> ConfigurationState {
    do {
      logger.info("Reading file at url=\(url)")
      let decoder = JSONDecoder()
      let data = try Data(contentsOf: url)
      let state = try decoder.decode(ConfigurationState.self, from: data)

      logger.info("Configuration loaded successfully")
      SwiftPrettyPrint.Pretty.print(state)

      return state
    } catch let error {
      logger.error("Failed reading configuration \(error)")
      return ConfigurationState(
        oscServerConfiguration: OSCServerConfiguration(
          host: "localhost",
          port: 8000
        ),
        sensors: []
      )
    }
  }
}
