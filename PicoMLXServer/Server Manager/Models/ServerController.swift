//
//  ServerController.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI

@Observable
final class ServerController {
    
    private (set) var servers = [Server]()
    
//    private (set) var activeServers = [Server]()
    
    func addServer(model: String = "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX", port: Int = 8080) throws {
        
        // Make sure port isn't in use
//        guard activeServers.filter({ $0.port == port && $0.operation != nil }).isEmpty else {
//            throw PicoError.portInUse(port)
//        }
        
        let server = Server(model: model, port: port)
        servers.append(server)
        try server.start()
    }
    
    func stopAllServers() {
        Queue.shared.cancelAllOperations()
    }
}
