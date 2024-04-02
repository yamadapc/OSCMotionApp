//
//  SCNVector3.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import SceneKit

extension SCNVector3 {
  func minus(_ other: Self) -> Self {
    return SCNVector3(self.x - other.x, self.y - other.y, self.z - other.z)
  }

  func plus(_ other: Self) -> Self {
    return SCNVector3(self.x + other.x, self.y + other.y, self.z + other.z)
  }

  func times(_ other: Self) -> Self {
    return SCNVector3(self.x * other.x, self.y * other.y, self.z * other.z)
  }
}
