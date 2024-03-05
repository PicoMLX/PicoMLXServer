//
//  ServerCellView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/19/24.
//

import SwiftUI

struct ServerCellView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(ServerController.self) private var serverController
    
    var server: Server
    @Binding var showError: Bool
    @Binding var error: Error?
    
    var body: some View {
        GridRow {
            Text(server.model)
                .fontWeight(.bold)
                .lineLimit(1)
                .truncationMode(.head)
            
            Text("\(String(server.port))")
            
            Button(server.isOn ? "Stop" : "Start") {
                if server.isOn {
                    server.stop()
                } else {
                    do {
                        try server.start()
                    } catch {
                        self.error = error
                        showError = true
                    }
                }
            }
            .controlSize(.small)
            
            Button("View Logs") {
                openWindow(id: "serverLog", value: server.id)
            }
            .controlSize(.small)
        }
    }
}

//#Preview {
//    ServerCellView()
//}
