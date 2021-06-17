//
//  SpawnPositionPacket.swift
//  DeltaCore
//
//  Created by Rohan van Klinken on 14/2/21.
//

import Foundation

struct SpawnPositionPacket: ClientboundPacket {
  static let id: Int = 0x42
  
  var location: Position

  init(from packetReader: inout PacketReader) throws {
    location = packetReader.readPosition()
  }
  
  func handle(for server: Server) throws {
    server.player.spawnPosition = location
    server.world?.finishDownloadingTerrain()
    
    // notify server that we are ready to finish login
    let clientStatus = ClientStatusPacket(action: .performRespawn)
    server.sendPacket(clientStatus)
  }
}