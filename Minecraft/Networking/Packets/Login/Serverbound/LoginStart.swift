//
//  LoginStart.swift
//  Minecraft
//
//  Created by Rohan van Klinken on 15/12/20.
//

import Foundation

struct LoginStart: Packet {
  typealias PacketType = LoginStart
  static let id: Int = 0x00
  
  var username: String
  
  func toBytes() -> [UInt8] {
    var writer = PacketWriter(packetId: LoginStart.id)
    writer.writeString(username)
    return writer.pack()
  }
}