//
//  BLEConnection.swift
//  WT901BLECL_Demo
//
//  Created by transistorgit on 26.11.20.
//
//  Bluetooth Access WIT Motion WT901BLECL IMU
//
//  Datasheet: https://drive.google.com/drive/folders/1NlOFHSTYNy2bRAfaA0S25BEaXK4uvia9

import CoreBluetooth
import Foundation
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: String(describing: BluetoothService.self)
)

class BluetoothService: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
  private var centralManager: CBCentralManager! = nil
  private var peripherals: [String: CBPeripheral] = [:]
  private var parsers: [String: Parser] = [:]
  private var gameState: GameState?

  func startCentralManager(gameState: GameState) {
    self.gameState = gameState
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  // Handles BT Turning On/Off
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      logger.info("Central scanning for peripherals...")
      self.centralManager.scanForPeripherals(
        withServices: nil,
        options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
      )

    default:
      logger.info("centralManagerDidUpdateState unknown state")
    }
  }

  // scan callback
  public func centralManager(
    _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any], rssi RSSI: NSNumber
  ) {
    guard let name = advertisementData["kCBAdvDataLocalName"] as? String else {
      return
    }

    if name == "HC-06" {
      logger.info("\(name) found ")
      self.peripherals[peripheral.identifier.uuidString] = peripheral
      self.parsers[peripheral.identifier.uuidString] = Parser()

      peripheral.delegate = self
      self.centralManager.connect(peripheral, options: nil)
    }
  }

  // connect callback
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    self.gameState?.onConnect(peripheral: peripheral.identifier.uuidString)
    logger.info("Connected to peripheral=\(peripheral.identifier)")
    peripheral.discoverServices(nil)
  }

  // connect failed callback
  public func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral error: Error?)
  {
    logger.error("failed to connect: \(error?.localizedDescription ?? "", privacy: .public)")
  }

  // disconnect callback
  public func centralManager(
    _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
  ) {
    logger.info("didDisconnectPeripheral \(error?.localizedDescription ?? "", privacy: .public)")
    self.gameState?.onDisconnect(peripheral: peripheral.identifier.uuidString)
  }

  // service discovery callback
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
      for service in services {
        logger.info("Discovered service \(service)")
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }

  // characteristics discovery callback
  public func peripheral(
    _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
  ) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        logger.info(
          "Discovered characteristic service=\(service.uuid) characteristic=\(characteristic.uuid)")
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }

  // data update callback - here the data from device arrives
  public func peripheral(
    _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?
  ) {

    guard let data = characteristic.value
    else {
      logger.error(
        "Error: didUpdateValueFor: \(characteristic.debugDescription) \(error.debugDescription)")
      return
    }

    guard let parser = self.parsers[peripheral.identifier.uuidString] else { return }
    let packets = parser.handleData(data)

    for packet in packets {
      self.gameState?.onReceivePacket(peripheral: peripheral.identifier.uuidString, packet: packet)
    }
  }
}
