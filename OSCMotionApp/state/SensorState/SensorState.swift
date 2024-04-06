//
//  SensorState.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation
import MIDIKit
import OSCKit
import SceneKit
import SwiftUI

#if os(macOS)
  typealias SCNFloat = CGFloat
#else
  typealias SCNFloat = Float
#endif

private func eulerToQuaternion(pitch: SCNFloat, roll: SCNFloat, yaw: SCNFloat) -> SCNQuaternion {
  // Create a temporary SCNNode
  let tempNode = SCNNode()

  // Set its Euler angles
  tempNode.eulerAngles = SCNVector3(x: pitch, y: yaw, z: roll)

  // Extract the quaternion
  return tempNode.orientation
}

let sensorAliases = [
  "914AC898-DBDA-2716-7A5F-260C0B8145A8": "L",
  "F9356C49-0869-7954-B347-ED65689B76AE": "R",
  "B299617D-FB93-E73D-E313-FA4F6B542424": "W",
  "73DE5E46-CAED-1EDF-F687-AA11CC60B2C2": "A",
  "406F4A02-13AE-E9C5-83DF-75F5FD57E023": "T",
]

class SensorState: ObservableObject, Identifiable {
  var id: String
  var node: SCNNode
  var motion: MotionState = MotionState()
  var scene = GameScene()
  var sensorConfiguration: SensorConfiguration
  var messageTransportService: MessageTransportService

  init(
    id: String,
    sensorConfiguration: SensorConfiguration,
    messageTransportService: MessageTransportService
  ) {
    self.id = id
    self.sensorConfiguration = sensorConfiguration

    self.messageTransportService = messageTransportService
    self.node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.01))
    self.node.geometry?.firstMaterial?.diffuse.contents = AppColor.purple
    self.node.position = SCNVector3(0, 0.7, 0)
    self.scene.rootNode.addChildNode(node)
  }

  func getAlias() -> String? {
    return sensorAliases[self.id]
  }

  func destroy() {
    self.node.removeFromParentNode()
  }

  func onReceivePacket(packet: SensorDataPacket) {
    motion.setMotionData(packet)

    let sensorConfiguration = self.sensorConfiguration
    self.messageTransportService.sendMessage(
      id: getAlias() ?? self.id,
      sensor: sensorConfiguration,
      packet: packet
    )

    guard let state = motion.anglesState else { return }
    node.orientation = eulerToQuaternion(
      pitch: state.x,
      roll: state.z,
      yaw: state.y
    )
  }

}
