//
//  OSCServerConfiguration.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation

class OSCServerConfiguration: ObservableObject, Codable {
  var serverURL: String

  init(serverURL: String) {
    self.serverURL = serverURL
  }
}
