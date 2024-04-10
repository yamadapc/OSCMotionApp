//
//  EventLogger.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 10/4/2024.
//

import Foundation

class EventLogger {
  private let fileURL: URL
  private var buffer: String = ""
  private let fileHandle: FileHandle
  private let queue = DispatchQueue(label: "eventLoggerQueue", attributes: .concurrent)
  private let bufferLimit = 1000 // Adjust buffer size as needed

  init?() {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "oscmotion-events.log"
    fileURL = documentsDirectory.appendingPathComponent(fileName)

    if !fileManager.fileExists(atPath: fileURL.path) {
      fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
    }

    do {
      fileHandle = try FileHandle(forWritingTo: fileURL)
      print("Logging to: \(fileURL.path)")
    } catch {
      print("Unable to open file: \(error)")
      return nil
    }
  }

  deinit {
    // Flush buffer and close the file handle when the object is deallocated
    queue.sync {
      self.flushBuffer()
    }
    fileHandle.closeFile()
  }

  func logEvent(_ event: String) {
    queue.async(flags: .barrier) {
      self.buffer.append("\(event)\n")
      if self.buffer.count >= self.bufferLimit {
        self.flushBuffer()
      }
    }
  }

  private func flushBuffer() {
    guard !buffer.isEmpty else { return }
    fileHandle.seekToEndOfFile()
    if let data = buffer.data(using: .utf8) {
      fileHandle.write(data)
    }
    buffer.removeAll()
  }
}

