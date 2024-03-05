//
//  Platform.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

struct Platform: Codable {
    
    let name: String
    
    // URL path to more info, usually project site. E.g. https://github.com/ml-explore
    let projectUrl: String
    
    // URL path to documentation, e.g. https://ml-explore.github.io/mlx/build/html/
    let documentationUrl: String
    
    let dependencies: [Dependency]
    
    // MARK: - Methods to load data from plist
    
    /// Loads all dependencies for all platforms from Dependencies.plist
    ///
    /// - Returns:  Array of DependencyPlatforms
    /// - Throws:   Codable error
    static func loadPlatforms() throws -> [Platform] {
        
        let dependenciesFile = Bundle.main.url(forResource: "Dependencies.plist", withExtension: nil)!
        let data = try Data(contentsOf: dependenciesFile)
        let decoder = PropertyListDecoder()
        return try decoder.decode([Platform].self, from: data)
    }
}
