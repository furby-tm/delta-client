//
//  LoginSuccessPacket.swift
//  DeltaCore
//
//  Created by Rohan van Klinken on 3/1/21.
//

import Foundation

struct LoginSuccessPacket: ClientboundPacket {
  static let id: Int = 0x02
  
  var uuid: UUID
  var username: String
  
  init(from packetReader: inout PacketReader) throws {
    uuid = try packetReader.readUUID()
    username = try packetReader.readString()
  }
  
  func handle(for server: Server) throws {
    server.connection.state = .play
  }
}