//
//  EntityRotationPacket.swift
//  DeltaCore
//
//  Created by Rohan van Klinken on 13/2/21.
//

import Foundation

struct EntityRotationPacket: ClientboundPacket {
  static let id: Int = 0x2a

  var entityId: Int
  var rotation: EntityRotation
  var onGround: Bool
  
  init(from packetReader: inout PacketReader) throws {
    entityId = packetReader.readVarInt()
    rotation = packetReader.readEntityRotation()
    onGround = packetReader.readBool()
  }
}