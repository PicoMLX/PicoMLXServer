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
            Table(serverController.servers) {
                
                TableColumn("Model") { server in
                    ModelView(server: server)
                }
                
                TableColumn("Port") { Text($0.port, format: .number.grouping(.never))}
                    .width(min: 30, ideal: 50, max: 100)
                
                TableColumn("Status") { server in
                    StatusView(server: server)
                }
                .width(min: 60, ideal: 60, max: 100)
                
                TableColumn("Action") { server in
                    OnOffButton(server: server)
                }
                .width(min: 40, ideal: 40, max: 100)
                
                TableColumn("Logs") { server in
                    Button("View") {
                        openWindow(id: "serverLog", value: server.id)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .width(min: 40, ideal: 40, max: 100)
            }
            .tableStyle(.bordered)
        } label: {
            Label("Servers", systemImage: "server.rack")
        }
    }
}
    
/// This is a workaround for an issue where an inline button in the Table wouldn't update
///  https://forums.swift.org/t/why-swiftui-table-doesn-t-track-changes-in-observable-object-is-there-are-bug-in-swiftui/70415
fileprivate struct OnOffButton: View {
    var server: Server
    var body: some View {
        Button(server.isOn ? "Stop" : "Start") {
            server.isOn.toggle()
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}

fileprivate struct StatusView: View {
    var server: Server
    var body: some View {
        Text(server.isOn ? "Running" : "Stopped")
    }
}

fileprivate struct ModelView: View {
    var server: Server
    var body: some View {
        Text(server.model)
            .fontWeight(.bold)
            .truncationMode(.head)
            .foregroundStyle(server.isOn ? .primary : .secondary)
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
