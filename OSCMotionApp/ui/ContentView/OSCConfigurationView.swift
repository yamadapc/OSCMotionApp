//
//  OSCConfigurationView.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 3/4/2024.
//

import Foundation
import SwiftUI

private struct FormItem<C: View>: View {
  var label: String
  var content: (String) -> C

  var body: some View {
    HStack {
      Text(label)
      content(label)
    }
  }
}

private let sensors: [MessageConfiguration] = [
  MessageConfiguration(id: "1"),
  MessageConfiguration(id: "2"),
  MessageConfiguration(id: "3"),
  MessageConfiguration(id: "4"),
  MessageConfiguration(id: "5"),
]

private struct SensorConfigurationView: View {
  @ObservedObject var state: MessageConfiguration

  var body: some View {
    Section("MIDI configuration") {}
    Section("OSC configuration") {}
  }
}

struct OSCConfigurationView: View {
  @ObservedObject var state: OSCServerConfiguration

  var body: some View {
    Form {
      Section("OSC Server") {
        FormItem(label: "Server URL") { label in
          TextField(label, text: $state.serverURL)
        }
      }

      ForEach(sensors, id: \.self.id) { state in
        Section("Sensor \(state.id)") {
          SensorConfigurationView(state: state)
        }
      }
    }
  }
}
