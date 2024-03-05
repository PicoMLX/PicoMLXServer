//
//  Server.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/17/24.
//

import Foundation
import OSLog

@Observable
final class Server: Identifiable {
    
    let logger = Logger(subsystem: "PicoMLXServer", category: "Server")
    
    let id = UUID()
    
    /// Model name on HuggingFace, e.g. "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX"
    var model: String = ""
    
    /// Port the server should listen to
    var port: Int = 8080
    
    /// Log data from server
    var log: String = ""
    
    var isOn: Bool {
        if let operation {
            if operation.isFinished || operation.isCancelled {
                return false
            } else if operation.isExecuting == false {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    /// Points to the ServerOperation in the server queue
    /// If not nil, this server is running
    weak var operation: ServerOperation? = nil
    
    init(model: String, port: Int) {
        self.model = model
        self.port = port
    }
    
    func start() throws {
        if operation == nil {
            let operation = try serverOperation()
            Queue.shared.serverQueue.addOperation(operation)
            self.operation = operation
        }
    }
    
    func stop() {
        operation?.cancel()
    }
    
    /// Creates a server operation
    /// - Returns: operation or nil
    private func serverOperation() throws -> ServerOperation {
        let operation = try ServerOperation(model: model, port: port, directory: "~")
        operation.outputClosure = { [weak self] in self?.log.append($0) }
        operation.completionBlock = { [self] in
            self.log.append("\nServer \(self.model) on port \(self.port) terminated")
        }
        return operation
    }
}

// Attempt to make server update in SwiftUI views by conforming to Hashable and Equatable protocol
extension Server: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isOn)
        hasher.combine(model)
        hasher.combine(port)
    }
}

extension Server: Equatable {
    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.id == rhs.id
    }
}
