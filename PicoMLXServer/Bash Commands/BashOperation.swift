//
//  BashOperation.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/12/24.
//
// See https://eclecticlight.co/2020/12/10/controlling-processes-and-environments/

import Cocoa
import OSLog

protocol BashOutputProtocol {
    
    /// Operation received stdOut output from shell
    /// Will always be called from the main thread
    func bashOperation(_ operation: BashOperation, receivedOutput string: String)
    
    /// Operation received error from shell
    /// Will always be called from the main thread
    func bashOperation(_ operation: BashOperation, receivedError string: String)
}

class BashOperation: Operation {
    
    let logger = Logger(subsystem: "PicoMLXServer", category: "BashOperation")
    
    /// Alternative to using
    var delegate: BashOutputProtocol?
    
    /// Closure to forward stdout
    var outputClosure: ((String) -> Void)?
    
    /// Closure to forward stderr
    var errClosure: ((String) -> Void)?
    
    /// If any of the commands in the script returns non-zero,
    /// the script will cancel and forward the exit code
    /// 0 is success, anything else is an error
    /// http://www.tldp.org/LDP/abs/html/exitcodes.html
    private (set) var exitStatus: Int?
    
    /// Complete output
    private (set) var output: String = ""
    
    private let task = Process()
    private let outputPipe = Pipe()
    private let inputPipe = Pipe()
    
    private let launchPath: String
    private var notification: NSObjectProtocol!
    private let arguments: [String]
    private let path: String

    /// Convenience initializer for generic Execute.command script
    ///
    /// - Parameters:
    ///   - script: <script>.command in the main bundle to be executed.
    ///   - path: Path of the <script>.command. If nil, main bundle will be assumed
    ///   - directory: directory where script will be run (e.g. project directory)
    ///   - commands: Commands to execute. Quotes will be added
    ///   - verboseStdout: if true (default), stdOut will include cd and command in output
    ///     (used for pretty output in console). If false, stdOut will only contain command's output
    /// - Throws: File not found if Bash script cannot be found
    init(script: String = "Execute", ext: String = "command", launchPath: String? = nil,
         directory: String = "~", path: [String]? = nil, commands: [String], verbose: Bool = true) throws {
        
        // 1. Prepare script location
        // Set launchPath to the location of the bash script to be executed
        if let path = launchPath {
            self.launchPath = URL(fileURLWithPath: path).appendingPathComponent(script).appendingPathExtension(ext).absoluteString
        } else if let path = Bundle.main.path(forResource: script, ofType: ext) {
            self.launchPath = path
        } else {
            throw PicoError.scriptNotFound(path: launchPath ?? "main bundle", file: script)
        }
        
        if let path {
            self.path = path.joined(separator: ":")
        } else {
            self.path = "/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin/:/usr/bin/python:/usr/bin/python3/:/opt/homebrew/Caskroom/miniforge/base/bin/"
        }
        
        // 2. Set location where the commands need to be executed
        // Expand ~ since NSTask does not do that
        var expandedDirectory = ""
        if directory == "~" {
            expandedDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        } else {
            expandedDirectory = directory.escapedSpaces
        }
        
        // 3. Set Bash arguments
        var arguments = [String]()
        if verbose == true {
            arguments.append("-v") // Only show command's output
        }
        arguments.append("-d")
        arguments.append(expandedDirectory)
        
        for command in commands {
            arguments.append(command)
        }

        self.arguments = arguments
    }
    
    override func main() {
        
        defer {
            NotificationCenter.default.removeObserver(notification as Any)
        }
        
        // main code, execute bash task
        guard isCancelled == false else {
            return
        }
        
        task.standardInput = self.inputPipe
        task.launchPath = self.launchPath
        task.arguments = self.arguments
        task.environment = [
            "PATH": self.path,
            "HOME": FileManager.default.homeDirectoryForCurrentUser.path,
        ]
        
        // Handle termination
        self.task.terminationHandler = { task in
            self.exitStatus = Int(task.terminationStatus)
        }
        
        // Handle output
        self.captureStandardOutput()
        
        task.launch()
        
        // Create a timer to check cancellation state every second
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                timer?.invalidate()
                return
            }

            if self.isCancelled {
                // The operation was cancelled, so terminate the task and invalidate the timer
                task.terminate()
                timer?.invalidate()
            }
        }
        
        task.waitUntilExit()
        timer?.invalidate()
    }
    
    /// For now, both stdout and stderr are sent to the same pipe.
    func captureStandardOutput() {
        
        task.standardOutput = outputPipe
        task.standardError = outputPipe
        
        notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            guard let outputString = String(data: output, encoding: String.Encoding.utf8), !outputString.isEmpty else { return }
            
            self.logger.info("\(outputString)")            
            self.outputClosure?(outputString)
            self.delegate?.bashOperation(self, receivedOutput: outputString)
            self.output = self.output + "\n" + outputString
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
}
