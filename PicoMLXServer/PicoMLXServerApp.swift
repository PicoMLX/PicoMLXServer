//
//  PicoMLXServerApp.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/4/24.
//

import SwiftUI
import FullDiskAccess

@main
struct PicoMLXServerApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var serverController = ServerController()
        
    init() {
        if !FullDiskAccess.isGranted {
            FullDiskAccess.promptIfNotGranted(
                title: "Enable Full Disk Access for Pico MLX Server",
                message: "Pico MLX Server requires Full Disk Access to search and install the MLX toolchain",
                settingsButtonTitle: "Open Settings",
                skipButtonTitle: "Later",
                canBeSuppressed: false,
                icon: nil
            )
        }
    }
    
    var body: some Scene {
        
        MenuBarExtra("Pico MLX Server", image: .mlxLogo) {
            MenuExtra()
                .environment(serverController)
        }
        .menuBarExtraStyle(.menu)
        
        Window("Setup", id: "setup") {
            SetupView()
                .environment(serverController)
        }
        
        Window("Servers", id: "servers") {
            ServerManagerView()
                .environment(serverController)
        }
        
        WindowGroup(id: "serverLog", for: UUID.self) { $serverUUID in
            ServerLogView(serverUUID: serverUUID)
                .environment(serverController)
        }
        
        Settings {
            SettingsView()
                .handlesExternalEvents(preferring: ["settings"], allowing: ["*"])
                .onOpenURL { url in
                    // this is never called, possibly a SwiftUI bug? https://swiftui-lab.com/nsuseractivity-with-swiftui/
                    print("SettingsView received: \(url)")
                }
                .frame(minWidth: 300, idealWidth: 600, minHeight: 300, idealHeight: 400)
                .environment(serverController)
        }
        .handlesExternalEvents(matching: ["settings"])
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillTerminate(_ notification: Notification) {
        Queue.shared.cancelAllOperations()
        // Threads check for cancelations every second
        // Wait to exit until all tasks have had the chance
        // to respond to the cancellation
        Thread.sleep(forTimeInterval: 1.5)
    }
}
