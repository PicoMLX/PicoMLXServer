//
//  DependencyState.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

enum DependencyState: Equatable, CustomStringConvertible {
    
    /// The installation state of the dependency is unknown. This is the initial state
    case unknown
         
    /// The installed version is older than required
    case outdated
    
    /// The dependency is not installed
    case notInstalled
    
    /// Installation is in progress
    case installing
    
    /// The dependency is installed and up-to-date
    case installed
    
    var buttonLabel: String {
        switch self {
        case .unknown:
            return "Searching..."
        case .notInstalled:
            return "Install"
        case .outdated, .installed:
            return "Update"
        case .installing:
            return "Installing..."
        }
    }
    
    var disableButton: Bool {
        switch self {
        case .installing, .unknown:
            return true
        default:
            return false
        }
    }
    
    var systemImage: String {
        switch self {
        case .unknown:
            return "questionmark.circle"
        case .outdated:
            return "exclamationmark.triangle"
        case .notInstalled:
            return "xmark.circle"
        case .installing:
            return "arrow.triangle.2.circlepath"
        case .installed:
            return "checkmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .unknown:
            "Searching..."
        case .outdated:
            "Outdated"
        case .notInstalled:
            "Not installed"
        case .installing:
            "Installing..."
        case .installed:
            "Installed"
        }
    }
}
