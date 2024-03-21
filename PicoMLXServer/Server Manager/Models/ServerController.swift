//
//  ServerController.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI

@Observable
final class ServerController {
    
    var servers = [Server]()
    
    func addServer(model: String = "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX", port: Int = 8080) throws {                
        
        let server = Server(model: model, port: port)
        servers.append(server)
        server.isOn = true
    }
    
    func stopAllServers() {
        Queue.shared.cancelAllOperations()
    }
}
