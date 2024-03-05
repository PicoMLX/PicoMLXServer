//
//  Queue.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

final class Queue {
    
    static let shared = Queue()
    
    /// Queue used to fetch versions (which can be slow)
    let versionQueue: OperationQueue = OperationQueue()
    
    /// Queue used to fetch paths of the dependencies (if installed)
    let fileQueue: OperationQueue = OperationQueue()
    
    /// Queue used to install and update tools
    let installQueue: OperationQueue = OperationQueue()
    
    /// Queue used for server
    let serverQueue: OperationQueue = OperationQueue()
    
    init() {
        fileQueue.maxConcurrentOperationCount = 1
        fileQueue.qualityOfService = .userInteractive
        versionQueue.maxConcurrentOperationCount = 1
        versionQueue.qualityOfService = .userInteractive
        installQueue.maxConcurrentOperationCount = 1
        installQueue.qualityOfService = .userInitiated
        serverQueue.maxConcurrentOperationCount = 10
        serverQueue.qualityOfService = .userInitiated
    }
    
    func cancelAllOperations() {
        versionQueue.cancelAllOperations()
        fileQueue.cancelAllOperations()
        installQueue.cancelAllOperations()
        serverQueue.cancelAllOperations()
    }
}
