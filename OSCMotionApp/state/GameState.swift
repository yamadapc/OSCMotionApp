//
//  GameState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation

class GameState: ObservableObject {
  var sensors: [String: SensorState] = [:]

  func onConnect(peripheral: String) {
    let sensor = SensorState(id: peripheral, midiChannel: self.sensors.count)
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
