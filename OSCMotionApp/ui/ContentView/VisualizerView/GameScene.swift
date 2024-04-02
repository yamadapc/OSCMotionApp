//
//  GameScene.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation
import SceneKit

class GameScene: SCNScene {
  var cameraNode = SCNNode()
  var velocity = SCNVector3(0, 0, 0)

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init() {
    super.init()

    background.contents = UIColor.black

    setupCamera()
    addFloor()
    addLights()
  }

  func setupCamera() {
    let camera = SCNCamera()
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(0, 5, 5)
    cameraNode.eulerAngles = SCNVector3(-Float.pi / 4, 0, 0)

    rootNode.addChildNode(cameraNode)
  }

  func addFloor() {
    let floor = SCNNode(geometry: SCNFloor())
    floor.geometry?.firstMaterial?.diffuse.contents = UIColor.gray

    rootNode.addChildNode(floor)
  }

  func addLights() {
    // Add ambient light.
    let ambientLightNode = SCNNode()
    let ambientLight = SCNLight()

    ambientLight.type = .ambient
    ambientLight.color = UIColor.white
    ambientLight.intensity = 72

    ambientLightNode.light = ambientLight

    rootNode.addChildNode(ambientLightNode)

    // Add spot light.
    let spotLightNode = SCNNode()
    let spotLight = SCNLight()

    spotLight.type = .spot
    spotLight.color = UIColor.orange
    spotLight.intensity = 2700
    spotLight.spotInnerAngle = 20
    spotLight.spotOuterAngle = 272
    spotLight.castsShadow = true

    spotLightNode.light = spotLight
    spotLightNode.position = SCNVector3(-1, 2, 0)
    spotLightNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)

    rootNode.addChildNode(spotLightNode)
  }
}
