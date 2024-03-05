//
//  PicoError.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/12/24.
//

import Foundation

enum PicoError: LocalizedError {
    case fileNotFound(String)
    case scriptNotFound(path: String, file: String)
    case configurationError(String)
    case portInUse(Int)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "File \(url) not found"
        case .scriptNotFound(path: let path, file: let file):
            return "Script not found: \(file) in directory \(path)"
        case .configurationError(let string):
            return "Configuration error: \(string)"
        case .portInUse(let port):
            return "Port \(port) is in use. Pause the other server first."
        }
    }
}
