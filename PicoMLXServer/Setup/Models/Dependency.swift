//
//  Dependency.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

/// Dependency is an application Composite depends on, e.g. truffle
class Dependency: Codable {
    
    /// Name of the dependency. If no filename is provided,
    /// name will be assumed to be the filename.
    /// The first character of name is automatically capitalized in the view model
    let name: String
    
    /// In case the filename is not the same as the dependency name, filename needs to be set
    let filename: String?
    
    /// Shell command
    let isInstalledCommand: String?
    
    /// Regex expression to parse isInstallCommand
    let isInstalledRegex: String?
    
    /// Optional minimum version required
    let minimumVersionRequired: String?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Optional text to display to the user why this dependency is required
    let comment: String?
    
    // MARK: - Commands
    
    /// Command to display version
    let versionCommands: [String]?
    
    /// Regex to fetch the version string
    let versionRegex: String?
    
    /// Command to install dependency
    let installCommands: [String]?
    
    /// Command to upgrade dependency to latest version
    let updateCommands: [String]?
    
    /// Command to check if dependency is up to date
    let outdatedCommands: [String]?
}

