//
//  GameState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation

class GameState: ObservableObject {
  var sensors: [String: SensorState] = [:]
  var configuration: ConfigurationState
  var messageTransportService: MessageTransportService

  init(
    configuration: ConfigurationState,
    messageTransportService: MessageTransportService
  ) {
    self.configuration = configuration
    self.messageTransportService = messageTransportService
  }

  func onConnect(peripheral: String) {
    let nextIndex = sensors.count % configuration.sensors.count
    let nextConfiguration = configuration.sensors[nextIndex]
    let sensor = SensorState(
      id: peripheral,
      sensorConfiguration: nextConfiguration,
      messageTransportService: messageTransportService
    )
    self.sensors[peripheral] = sensor
    self.objectWillChange.send()
  }

  func onDisconnect(peripheral: String) {
    if let state = self.sensors.removeValue(forKey: peripheral) {
      state.destroy()
    }
    self.objectWillChange.send()
  }

  func onReceivePacket(peripheral: String, packet: SensorDataPacket) {
    guard let sensor = self.sensors[peripheral] else { return }
    sensor.onReceivePacket(packet: packet)
  }
}
