//
//  ContentView.swift
//  WT901BLECL_Demo
//
//  Created by transistorgit on 26.11.20.
//

import Charts
import CoreBluetooth
import CoreData
import MIDIKit
import SceneKit
import SwiftUI

struct ContentView: View {
  @State var bleConnection = BluetoothService()
  @State var messageTransportService: MessageTransportService
  @State var isErrorShown: Bool = false
  var configuration = ConfigurationState.loadFromFile(
    url: URL(
      string: "file:///Users/yamadapc/Documents/Max 8/Projects/OSCMotion/OSCMotionApp/config.json")!
  )
  @ObservedObject var gameState: GameState
  @State var enableVisualisations: Bool = true

  init() {
    let messageTransportService = MessageTransportService(
      configuration: configuration.oscServerConfiguration
    )
    gameState = GameState(
      configuration: configuration,
      messageTransportService: messageTransportService
    )
    self.messageTransportService = messageTransportService
  }

  var body: some View {
    VStack {
      Toggle(isOn: $enableVisualisations, label: { Text("Enable visuals") })
      HStack {
        if gameState.sensors.isEmpty {
          Text("Searching for sensors...")
        }

        ForEach(Array(gameState.sensors.values)) { sensor in
          VStack {
            if enableVisualisations {
              VisualizerView(scene: sensor.scene)
            }
            Text(sensor.getAlias() ?? "Unknown \(sensor.id)")
          }
        }
      }
    }
    .onAppear {
      self.connectBLEDevice()
      do {
        try messageTransportService.start()
      } catch let error {
        let _ = self.alert(
          "Error", isPresented: $isErrorShown, actions: {},
          message: {
            Text(error.localizedDescription)
          })
      }
    }
    .padding()
  }

  private func connectBLEDevice() {
    bleConnection.startCentralManager(gameState: gameState)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
