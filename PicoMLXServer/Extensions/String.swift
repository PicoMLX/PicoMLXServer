//
//  String.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/12/24.
//

import Foundation

extension String {
    
    public var escapedSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }
}
