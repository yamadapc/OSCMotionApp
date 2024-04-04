//
//  MessageTransportService.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 5/4/2024.
//

import Foundation
import MIDIKit
import OSCKit
import SceneKit
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: String(describing: MessageTransportService.self)
)

private func sendMIDI(
  midiChannel: Int,
  midiMessageConfiguration: MIDIMessageConfiguration?,
  value: Double
) {
  guard let midiMessageConfiguration = midiMessageConfiguration else { return }
  for (_, output) in midiManager.managedOutputs {
    let valueNum: Double = abs(127.0 * min(1.0, max(value, 0.0)))
    let value: MIDIEvent.CC.Value = MIDIEvent.CC.Value.midi1(UInt7(valueNum))
    let event: MIDIEvent = .cc(
      MIDIEvent.CC(
        controller: MIDIEvent.CC.Controller.init(number: UInt7(midiMessageConfiguration.midiCC)),
        value: value,
        channel: UInt4(midiChannel)
      )
    )
    try! output.send(event: event)
  }
}

let messageConfiguration: [String: MessageConfiguration] = [
  "angle/x": MessageConfiguration(
    midi: MIDIMessageConfiguration(
      midiCC: MIDIEvent.CC.Controller.generalPurpose1.number.intValue,
      midiRangeStart: nil,
      midiRangeEnd: nil
    ),
    osc: OSCMessageConfiguration()
  ),
  "angle/y": MessageConfiguration(
    midi: MIDIMessageConfiguration(
      midiCC: MIDIEvent.CC.Controller.generalPurpose2.number.intValue,
      midiRangeStart: nil,
      midiRangeEnd: nil
    ),
    osc: OSCMessageConfiguration()
  ),
  "angle/z": MessageConfiguration(
    midi: MIDIMessageConfiguration(
      midiCC: MIDIEvent.CC.Controller.generalPurpose3.number.intValue,
      midiRangeStart: nil,
      midiRangeEnd: nil
    ),
    osc: OSCMessageConfiguration()
  ),
]

struct Message {
  let id: String
  let value: Double
}

/// Sends data through MIDI and OSC
class MessageTransportService {
  let oscClient = OSCClient()
  let configuration: OSCServerConfiguration

  init(configuration: OSCServerConfiguration) {
    self.configuration = configuration
  }

  func sendMessage(
    sensor: SensorConfiguration,
    packet: SensorDataPacket
  ) {
    let midiChannel = sensor.midiConfiguration.midiChannel
    var messages: [Message] = []
    messages.append(
      contentsOf: self.getAngleMessages(packet: packet)
    )

    do {
      for message in messages {
        sendMIDI(
          midiChannel: midiChannel,
          midiMessageConfiguration: messageConfiguration[message.id]?.midi,
          value: message.value
        )

        let message = OSCMessage(
          "/sensor/\(sensor.id)/\(message.id)",
          values: [
            Int(message.value * 1000)
          ]
        )
        try oscClient.send(
          message,
          to: configuration.host,
          port: UInt16(configuration.port)
        )
      }
    } catch let err {
      logger.error("Failed to send messages \(err)")
    }
  }

  func getAngleMessages(packet: SensorDataPacket) -> [Message] {
    switch packet {
    case .angle(let x, let y, let z, temperature: _):
      return [
        Message(
          id: "angle/x",
          value: (Double.pi + Double(x)) / (Double.pi * 2)
        ),
        Message(
          id: "angle/y",
          value: (Double.pi + Double(y)) / (Double.pi * 2)
        ),
        Message(
          id: "angle/z",
          value: (Double.pi + Double(z)) / (Double.pi * 2)
        ),
      ]
    default:
      break
    }

    return []
  }

  func start() throws {
    try midiManager.start()
    try midiManager.addOutput(
      name: "OSCMotionoutput",
      tag: "OSCMotion",
      uniqueID: .adHoc
    )
  }
}
