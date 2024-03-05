//
//  ServerOperation.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import Foundation

class ServerOperation: BashOperation, Identifiable {
    
    let model: String
    let port: Int
    let id: UUID
        
    init(model: String, port: Int, launchPath: String? = nil, directory: String = "~", path: [String]? = nil, verbose: Bool = true) throws {
        
        guard let serverScriptPath = Bundle.main.path(forResource: "server", ofType: "py") else {
            throw PicoError.fileNotFound("server.py")
        }
        
        self.model = model
        self.port = port
        self.id = UUID()
        let commands: [String]
        if UserDefaults.standard.bool(forKey: "useConda") == true || UserDefaults.standard.object(forKey: "useConda") == nil {
            commands = ["conda activate pico", "python3 \(serverScriptPath) model=\(model) port=\(port)", "conda deactivate"]
        } else {
            commands = ["python3 \(serverScriptPath) model=\(model) port=\(port)"]
        }
        
        try super.init(script: "Execute", ext: "command", launchPath: launchPath, directory: directory, path: path, commands: commands, verbose: verbose)
    }
}
