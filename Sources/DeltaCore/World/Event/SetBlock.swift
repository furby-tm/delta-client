//
//  SetBlock.swift
//  DeltaCore
//
//  Created by Rohan van Klinken on 1/6/21.
//

import Foundation

extension World.Event {
  struct SetBlock: Event {
    let position: Position
    let newState: UInt16
  }
}