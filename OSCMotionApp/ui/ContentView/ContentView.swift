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
  var bleConnection = BluetoothService()
  @ObservedObject var gameState = GameState()
  @State var isErrorShown: Bool = false

  var body: some View {
    HStack {
      ForEach(Array(gameState.sensors.values)) { sensor in
        VisualizerView(scene: sensor.scene)
      }
    }
    .onAppear {
      self.connectBLEDevice()
      do {
        try midiManager.start()
        try midiManager.addOutput(name: "OSCMotionoutput", tag: "OSCMotion", uniqueID: .adHoc)
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
    bleConnection.startCentralManager(state: gameState)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
