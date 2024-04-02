//
//  VisualizerView.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import SceneKit
import SwiftUI

struct VisualizerView: View {
  var scene: GameScene
  var body: some View {
    SceneView(scene: scene, pointOfView: scene.cameraNode, options: .allowsCameraControl)
  }
}
