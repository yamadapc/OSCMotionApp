//
//  SensorDataPacket.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation

enum SensorDataPacket: Equatable {
  case acceleration(x: Double, y: Double, z: Double, temperature: Double)
  case angularVelocity(x: Double, y: Double, z: Double, temperature: Double)
  // roll, pitch, yaw ; radians
  case angle(x: Double, y: Double, z: Double, temperature: Double)
}
