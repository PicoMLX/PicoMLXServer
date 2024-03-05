//
//  NSApplication.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//
// Source: https://stackoverflow.com/questions/74670498/macos-swiftui-menu-bar-app-settings-opening-in-background

import Cocoa

extension NSApplication {

    static func show(ignoringOtherApps: Bool = true) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: ignoringOtherApps)        
    }

    static func hide() {
        NSApp.hide(self)
        NSApp.setActivationPolicy(.accessory)
    }
}
