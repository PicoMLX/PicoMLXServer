//
//  DependencyViewModel+Operations.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

extension DependencyViewModel {
    
    
    /// Creates an operation that finds the location of the dependency.
    /// If the dependency isn't installed, it will set the state to .notInstalled
    ///
    /// - Returns: operation or nil
    func fileLocationOperation() -> BashOperation? {
        
        let command = self.isInstalledCommand ?? "which \(self.name)"
        guard let operation = try? BashOperation(commands: [command], verbose: false)
            else { return nil }
        
        operation.outputClosure = output
        operation.completionBlock = { [self] in
            
            guard !operation.output.isEmpty, !operation.output.contains("not found") else {
                self.state = .notInstalled
                return
            }
            
            if let expression = self.isInstalledRegex {
                guard let regex = try? NSRegularExpression(pattern: expression, options: .caseInsensitive) else {
                    self.path = nil
                    self.state = .notInstalled
                    return
                }
                if let _ = regex.firstMatch(in: operation.output, options: [], range: NSRange(location: 0, length: operation.output.count)) {
                    self.path = "private path"
                    self.state = .installed
                }
            } else {
                // stdoutput will be a file URL
                // Remove the double forward slash the 'which' command returns
                let url = URL(fileURLWithPath: operation.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).standardizedFileURL
                self.path = url.path
                self.state = .installed
            }
        }
        return operation
    }
    
    
    /// Fetches the version of the dependency
    ///
    /// - Returns: operation or nil
    func versionOperation() -> BashOperation? {
        
        guard
            let command = versionCommands,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: command)
            else { return nil }
        
        operation.outputClosure = output
        operation.completionBlock = { [self] in
            if let versions = self.versionQueryParser(operation.output), let version = versions.first {
                self.versionInstalled = version.trimmingCharacters(in: .whitespaces)
                
                // Update state
                if let minimumVersionRequired, minimumVersionRequired.compare(versionInstalled, options: .numeric) == .orderedDescending {
                    self.state = .outdated
                } else {
                    self.state = .installed
                }
                
            } else {
                self.versionInstalled = ""
            }
        }
        return operation
    }
    
    /// Run this after the operation has finished. Pass the operation's output property
    ///
    /// - Parameter output: output of the operation
    /// - Returns: parsed version numbers found in output
    private func versionQueryParser(_ output: String) -> [String]? {
        
        // Filter 1.0.1-rc1 type version number
        // Some apps return multiple lines, and this closure will be called multiple times.
        // Therefore, if no match if found, the output closure will not be called, since the
        // version number could be in the previous or next line.
        guard let versionRegex, let regex = try? NSRegularExpression(pattern: versionRegex, options: .caseInsensitive) else {
            return nil
        }
        let versions = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count)).map {
            String(output[Range($0.range, in: output)!])
        }
        
        // Some dependencies return multiple lines for their version information
        // Return the first one
        return versions
    }
    
    func installOperation() -> [BashOperation]? {
        
        // If dependency is already installed, return nil
        guard state == .notInstalled else { return nil }
        state = .installing
        
        guard let commands = installCommands, 
              commands.isEmpty == false,
              let operation = try? BashOperation(directory: "~", commands: commands) else {
            return nil
        }
        operation.outputClosure = output
        
        let operations = [operation, fileLocationOperation(), versionOperation()].compactMap{ $0 }
        return operations
    }
    
    func updateOperation() -> [BashOperation]? {
        guard
            let commands = updateCommands,
            commands.isEmpty == false,
            state != .notInstalled,
            let operation = try? BashOperation(directory: "~", commands: commands)
            else { return nil }        
        state = .installing
        operation.outputClosure = output
        
        let operations = [operation, versionOperation()].compactMap{ $0 }
        return operations
    }
}
