//
//  SensorState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation
import SwiftUI
import MIDIKit
import OSCKit
import SceneKit

private func eulerToQuaternion(pitch: CGFloat, roll: CGFloat, yaw: CGFloat) -> SCNQuaternion {
  // Create a temporary SCNNode
  let tempNode = SCNNode()

  // Set its Euler angles
  tempNode.eulerAngles = SCNVector3(x: pitch, y: yaw, z: roll)

  // Extract the quaternion
  return tempNode.orientation
}

private func sendMIDI(cc: MIDIEvent.CC.Controller, midiChannel: Int, value: Double) {
  for (_, output) in midiManager.managedOutputs {
    let valueNum: Double = abs(127.0 * min(1.0, max(value, 0.0)))
    let value: MIDIEvent.CC.Value = MIDIEvent.CC.Value.midi1(UInt7(valueNum))
    let event: MIDIEvent = .cc(
      MIDIEvent.CC(
        controller: cc,
        value: value,
        channel: UInt4(midiChannel)
      )
    )
    try! output.send(event: event)
  }
}

class SensorState: ObservableObject, Identifiable {
  var id: String
  var node: SCNNode
  var motion: MotionState = MotionState()
  var scene = GameScene()
  var midiChannel: Int

  init(id: String, midiChannel: Int) {
    self.id = id
    self.midiChannel = midiChannel
    self.node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.01))
    self.node.geometry?.firstMaterial?.diffuse.contents = Color.purple
    self.node.position = SCNVector3(0, 0.7, 0)
    self.scene.rootNode.addChildNode(node)
  }

  func destroy() {
    self.node.removeFromParentNode()
  }

  func onReceivePacket(packet: SensorDataPacket) {
    motion.setMotionData(packet)
    guard let state = motion.anglesState
    else { return }
    node.orientation = eulerToQuaternion(pitch: state.x, roll: state.z, yaw: state.y)

    sendMIDI(
      cc: .generalPurpose1, midiChannel: midiChannel,
      value: (Double.pi + Double(state.x)) / (Double.pi * 2))
    sendMIDI(
      cc: .generalPurpose2, midiChannel: midiChannel,
      value: (Double.pi + Double(state.y)) / (Double.pi * 2))
    sendMIDI(
      cc: .generalPurpose3, midiChannel: midiChannel,
      value: (Double.pi + Double(state.z)) / (Double.pi * 2))

    // guard let acceleration = motion.anglesAcceleration
    //   else { return }
    // self.velocity = velocity.plus(acceleration.times(SCNVector3(2, 2, 2))).times(
    //   SCNVector3(0.99, 0.99, 0.99))
    // sphere.eulerAngles = sphere.eulerAngles.plus(velocity)
  }
}
