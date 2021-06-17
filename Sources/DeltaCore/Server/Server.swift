//
//  Server.swift
//  DeltaCore
//
//  Created by Rohan van Klinken on 13/12/20.
//

import Foundation

class Server: Observable, Hashable {
  var managers: Managers
  var connection: ServerConnection
  var descriptor: ServerDescriptor
  var config: ServerConfig
  var tabList = TabList()
  
  var recipeRegistry = RecipeRegistry()
  var packetRegistry: PacketRegistry
  
  var world: World?
  
  var timeOfDay: Int = -1
  var difficulty: Difficulty = .normal
  var isDifficultyLocked: Bool = true
  var player: Player
  
  var eventManager = EventManager<ServerEvent>()
  
  var account: Account
  
  // Init
  
  init(descriptor: ServerDescriptor, managers: Managers) { // TODO: remove need for passing managers
    self.descriptor = descriptor
    self.managers = managers
    
    account = managers.configManager.getSelectedAccount() ?? OfflineAccount(username: "error")
    player = Player(username: account.name)
    
    config = ServerConfig.createDefault()
    packetRegistry = PacketRegistry.createDefault()
    
    connection = ServerConnection(host: descriptor.host, port: descriptor.port, eventManager: eventManager)
    super.init()
    connection.setPacketHandler(handlePacket)
  }
  
  // World
  
  func joinWorld(info: World.Info) {
    let newWorld = World(info: info, managers: managers)
    notifyObservers(Server.Event.JoinWorld(world: newWorld))
    world = newWorld
  }
  
  // Networking
  
  func login() {
    connection.login(username: player.username)
  }
  
  func sendPacket(_ packet: ServerboundPacket) {
    connection.sendPacket(packet)
  }
  
  func handlePacket(_ packetReader: PacketReader) {
    do {
      if let packetState = connection.state.toPacketState() {
        var reader = packetReader
        reader.locale = managers.localeManager.currentLocale
        
        guard let packetType = packetRegistry.getClientboundPacketType(withId: reader.packetId, andState: packetState) else {
          log.warning("non-existent packet received with id 0x\(String(reader.packetId, radix: 16))")
          return
        }
        
        let packet = try packetType.init(from: &reader)
        try packet.handle(for: self)
      }
    } catch {
      log.warning("failed to handle packet: \(error)")
    }
  }
  
  // Conformance: Hashable
  
  static func == (lhs: Server, rhs: Server) -> Bool {
    return (lhs.descriptor.name == rhs.descriptor.name && lhs.descriptor.host == rhs.descriptor.host && lhs.descriptor.port == rhs.descriptor.port)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(descriptor.name)
    hasher.combine(descriptor.host)
    hasher.combine(descriptor.port)
  }
}