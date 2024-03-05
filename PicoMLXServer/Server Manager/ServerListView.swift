//
//  ActiveServersView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI
import OSLog

struct ServerListView: View {
    
    let logger = Logger(subsystem: "PicoMLXServer", category: "ServerListView")
    @Environment(ServerController.self) private var serverController
    @Environment(\.openWindow) var openWindow
    
    @Binding var showError: Bool
    @Binding var error: Error?
        
    var body: some View {
            GroupBox {
                ScrollView() {
                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(serverController.servers,  id: \.self) { server in
                            ServerCellView(server: server, showError: $showError, error: $error)
                            Divider()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
        } label: {
            Label("Servers", systemImage: "server.rack")
        }
    }
}

#Preview {
    struct Preview: View {
        @State var showError = false
        @State var error: Error? = nil
        
        var body: some View {
            ServerListView(showError: $showError, error: $error)
                .environment(ServerController())
        }
    }
    return Preview()
}
