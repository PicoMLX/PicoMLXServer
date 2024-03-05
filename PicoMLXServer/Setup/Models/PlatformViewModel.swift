//
//  PlatformViewModel.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import Foundation

@Observable final class PlatformViewModel: Identifiable {
    
    var state: DependencyState = .unknown
    
    let name: String
    let projectUrl: String
    let documentationUrl: String
    var dependencies: [DependencyViewModel]
    
    init(platform: Platform) {
        name = platform.name
        projectUrl = platform.projectUrl
        documentationUrl = platform.documentationUrl
        dependencies = platform.dependencies.map { DependencyViewModel(dependency: $0) }
    }
}
