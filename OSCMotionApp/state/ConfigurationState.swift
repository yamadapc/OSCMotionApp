//
//  ConfigurationState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import os

fileprivate let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: String(describing: ConfigurationState.self)
)

class ConfigurationState: ObservableObject, Decodable {
  var oscServerConfiguration: OSCServerConfiguration
  var sensorsMessageConfiguration: [MessageConfiguration]

  init(oscServerConfiguration: OSCServerConfiguration, sensorsMessageConfiguration: [MessageConfiguration]) {
    self.oscServerConfiguration = oscServerConfiguration
    self.sensorsMessageConfiguration = sensorsMessageConfiguration
  }

  static func loadFromFile(url: URL) -> ConfigurationState {
    do {
      logger.info("Reading file at url=\(url)")
      let decoder = JSONDecoder()
      let data = try Data(contentsOf: url)
      let state = try decoder.decode(ConfigurationState.self, from: data)

      return state
    } catch let error {
      logger.error("Failed reading configuration \(error)")
      return ConfigurationState(
        oscServerConfiguration: OSCServerConfiguration(serverURL: "localhost"),
        sensorsMessageConfiguration: []
      )
    }
  }
}
