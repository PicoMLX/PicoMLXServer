//
//  DependencyViewModel.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation
import OSLog

@Observable final class DependencyViewModel: Identifiable {
    
    let logger = Logger(subsystem: "PicoMLXServer", category: "DependencyViewModel")
    
    // Keeps track of installation and update operations
    private var installOperations = NSPointerArray.weakObjects()
    private var updateOperations = NSPointerArray.weakObjects()
    
    /// OperationQueue output
    var output: (String)->Void = {_ in }
    
    var state: DependencyState = .unknown
    
    var versionInstalled = ""
    
    var path: String? = nil
    
    let name: String
    
    let filename: String?
    
    /// Optional text to display to the user why this dependency is required
    let comment: String?
    
    // MARK: - Shell commands and output parsers
    
    /// Command to check if dependency is installed
    let isInstalledCommand: String?
    
    /// Regex expression to parse isInstallCommand
    let isInstalledRegex: String?
    
    /// Version of this dependency is forwarded to the framework
//    let isFrameworkVersion: Bool
    
    /// Optional minimum version required
    let minimumVersionRequired: String?
    
    /// Command to install dependency
    let installCommands: [String]?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Version commands
    let versionCommands: [String]?
    let versionRegex: String?
    
    /// Command to upgrade dependency to latest version
    let updateCommands: [String]?
    
    init(dependency: Dependency) {
        name = dependency.name
        filename = dependency.filename
        isInstalledRegex = dependency.isInstalledRegex
        minimumVersionRequired = dependency.minimumVersionRequired
        installLink = dependency.installLink
        comment = dependency.comment
        versionCommands = dependency.versionCommands
        versionRegex = (dependency.versionRegex ?? "").isEmpty ? "(\\d+)\\.(\\d+)\\.(\\d+)\\-?(\\w+)?" : dependency.versionRegex!
        updateCommands = dependency.updateCommands
        installCommands = dependency.installCommands
        
        if let isInstalledCommand = dependency.isInstalledCommand, !isInstalledCommand.isEmpty {
            self.isInstalledCommand = isInstalledCommand
        } else if let filename = dependency.filename, !filename.isEmpty {
            self.isInstalledCommand = "which " + filename
        } else if !dependency.name.isEmpty {
            self.isInstalledCommand = "which " + name
        } else {
            self.isInstalledCommand = nil
        }
    }
}


// MARK: - Actions
extension DependencyViewModel {
    
    // Action for button press in SetupView
    func action() throws -> URL? {
        switch self.state {
        case .unknown, .installing:
            break
        case .outdated, .installed:
            if let operations = updateOperation() {
                Queue.shared.installQueue.addOperations(operations, waitUntilFinished: false)
            } else {
                logger.error("Could not create update operation")
            }
        case .notInstalled:
            if let installLink{
                // In case the app isn't able to install the dependency (e.g. Brew which need admin access)
                // we're taking the user a download link
                guard let url = URL(string: installLink) else { throw PicoError.configurationError("\(installLink) in Dependencies.plist is not a valid URL") }
                return url
            } else if let operations = installOperation() {
                Queue.shared.installQueue.addOperations(operations, waitUntilFinished: false)
            }
        }
        return nil
    }
    
    func setInitialState() {
        if let fileLocationOperation = fileLocationOperation(), let versionOperation = versionOperation() {
            Queue.shared.fileQueue.addOperation(fileLocationOperation)
            Queue.shared.versionQueue.addOperation(versionOperation)
        }
    }
}
