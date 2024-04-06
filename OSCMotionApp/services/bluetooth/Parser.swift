//
//  Parser.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Collections
import Foundation
import os

func hexadecimalRepresentation(of byteArray: some Sequence<UInt8>) -> String {
  let hexString = byteArray.map { String(format: "%02X", $0) }.joined(separator: " ")
  return hexString
}

class Parser {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: Parser.self)
  )

  private var dataBuffer: Deque<UInt8> = []

  init() {
  }

  func handleData(_ data: Data) -> [SensorDataPacket] {
    let dataBytes = [UInt8](data)
    let processedResults = processReceivedData(dataBytes: dataBytes)

    return processedResults
  }

  private func processReceivedData(dataBytes: [UInt8]) -> [SensorDataPacket] {
    let HEADER: UInt8 = 0x55
    let ACCELERATION: UInt8 = 0x51
    let ANGULAR_VELOCITY: UInt8 = 0x52
    let ANGLE: UInt8 = 0x53

    var processedData: [SensorDataPacket] = []

    guard !dataBytes.isEmpty else {
      return processedData
    }

    dataBuffer += dataBytes
    while dataBuffer.count > 0 && dataBuffer[0] != HEADER {
      dataBuffer.removeFirst()
    }

    while dataBuffer.count >= 11 {
      let packet = dataBuffer[0..<11]

      let checksum = packet[10]
      var expectedSum: UInt8 = 0
      for value in packet[0..<10] {
        expectedSum = expectedSum &+ value
      }

      if checksum != expectedSum {
        // Parser.logger.info("Checksum mismatch \(checksum) \(expectedSum)")
      } else {
        switch packet[1] {
        case ACCELERATION:
          let ax = Double(UInt16(packet[3] << 8 | packet[2])) / 32768.0 * 16
          let ay = Double(UInt16(packet[5] << 8 | packet[4])) / 32768.0 * 16
          let az = Double(UInt16(packet[7] << 8 | packet[6])) / 32768.0 * 16
          let temperature = Double(UInt16(packet[9] << 8 | packet[8])) / 340.0 + 36.25
          let data = SensorDataPacket.acceleration(x: ax, y: ay, z: az, temperature: temperature)
          processedData.append(data)
        case ANGULAR_VELOCITY:
          let wx = Double(Int16(packet[3]) << 8 | Int16(packet[2])) / 32768.0 * 2000
          let wy = Double(Int16(packet[5]) << 8 | Int16(packet[4])) / 32768.0 * 2000
          let wz = Double(Int16(packet[7]) << 8 | Int16(packet[6])) / 32768.0 * 2000
          let temperature = Double(Int16(packet[9]) << 8 | Int16(packet[8])) / 340.0 + 36.25
          let data = SensorDataPacket.angularVelocity(x: wx, y: wy, z: wz, temperature: temperature)
          processedData.append(data)
        case ANGLE:
          let angleX = Double(Int16(packet[3]) << 8 | Int16(packet[2])) / 32768.0 * Double.pi
          let angleY = Double(Int16(packet[5]) << 8 | Int16(packet[4])) / 32768.0 * Double.pi
          let angleZ = Double(Int16(packet[7]) << 8 | Int16(packet[6])) / 32768.0 * Double.pi
          let temperature = Double(Int16(packet[9]) << 8 | Int16(packet[8])) / 340.0 + 36.25
          let data = SensorDataPacket.angle(
            x: angleX, y: angleY, z: angleZ, temperature: temperature)
          processedData.append(data)
        default:
          break
        }
      }

      // Uncomment to log
      // let packetStr = hexadecimalRepresentation(of: packet)
      // Parser.logger.info("Packet received \(packetStr)")

      for _ in 0...packet.count {
        let _ = dataBuffer.popFirst()
      }
    }

    return processedData
  }
}
