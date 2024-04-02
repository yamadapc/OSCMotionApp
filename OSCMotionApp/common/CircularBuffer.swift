//
//  CircularBuffer.swift
//  OSCMotionApp
//
//  Created by Pedro Tacla Yamada on 30/3/2024.
//

import Foundation

struct CircularBuffer<T> {
  private var data: [T]
  private var head: Int = 0, tail: Int = 0
  private var capacity: Int
  private var count: Int = 0

  init(capacity: Int) {
    self.capacity = capacity
    self.data = [T]()
    self.data.reserveCapacity(capacity)
  }

  mutating func append(_ element: T) {
    if count < capacity {
      data.append(element)
      tail = (tail + 1) % capacity
      count += 1
    } else {
      data[head] = element
      head = (head + 1) % capacity
      tail = head
    }
  }

  func last(n: Int) -> [T] {
    var items = [T]()
    var current = tail
    for _ in 0..<min(n, count) {
      current = (current - 1 + capacity) % capacity
      items.append(data[current])
    }
    return items.reversed()
  }
}
