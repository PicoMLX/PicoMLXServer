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
                    MenuToggle(server: server, isOn: server.isOn)
                }
            }
            
            Divider()
            
            Button("New Server...") {
                NSApplication.show()
                openWindow(id: "servers")
            }            
            
            Button("Show cache...") {
                let url = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".cache/huggingface/hub/")
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            }
            .controlSize(.small)
        }
    }
}

#Preview {
    ServerListMenu()
        .environment(ServerController())
}

struct MenuToggle: View {
    
    let server: Server
    @State var isOn: Bool
    
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
