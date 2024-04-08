//
//  MotionState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import SceneKit

enum MotionParameter {
  case velocity
  case acceleration
  case anglesState
}

/// The state of a sensor motion only.
///
/// See  SensorState for the UI state as well and OSC handling.
class MotionState: ObservableObject {
  @Published var motionData: SensorDataPacket? = nil
  @Published var anglesVelocity: SCNVector3? = nil
  @Published var anglesAcceleration: SCNVector3? = nil
  @Published var anglesState: SCNVector3? = nil
  // @Published var previousData = CircularBuffer<SensorDataPacket>(capacity: 100)

  var flush: (() -> Void)?
  var timer: Timer?

  init() {
  }

  func start() {
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
      self.flush?()
    }
  }

  func setMotionData(_ motionData: SensorDataPacket?) {
    guard let motionData = motionData else { return }

    if self.timer == nil {
      self.start()
    }

    switch motionData {
    case .angle(x: let roll, y: let pitch, z: let yaw, temperature: _):
      let currVector = SCNVector3(pitch, roll, 0)
      let prevVector =
        self.motionData != nil
        ? SCNVector3(pitch, roll, 0)
        : currVector
      let currVelocity = currVector.minus(prevVector)
      let currAcceleration =
        self.anglesVelocity != nil
        ? currVelocity.minus(self.anglesVelocity!)
        : SCNVector3(0, 0, 0)

      self.flush = {
        self.motionData = motionData
        self.anglesVelocity = currVelocity
        self.anglesState = SCNVector3(pitch, yaw, roll)
        self.anglesAcceleration = currAcceleration
      }
    default:
      break
    }

    self.motionData = motionData
  }
}
