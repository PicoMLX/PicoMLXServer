//
//  ServerListMenu.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI
import AppKit

struct ServerListMenu: View {
    
    @Environment(ServerController.self) private var serverController
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Menu("Servers") {
            if serverController.servers.isEmpty {
                Text("No servers created")
                    .disabled(true)
            } else {
                ForEach(serverController.servers,  id: \.self) { server in
                    MenuToggle(server: server)
                }
            }
        }
    }
}

#Preview {
    ServerListMenu()
        .environment(ServerController())
}

/// This is a workaround for an issue where an inline toggle in the menu wouldn't update
fileprivate struct MenuToggle: View {
    
    let server: Server
    
    var body: some View {
        @Bindable var server = server
        Toggle(isOn: $server.isOn) {
            Text("\(server.model):\(String(server.port))")
                .truncationMode(.head)
        }
        .onAppear {
            print(server.isOn)
        }
    }
}
