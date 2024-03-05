//
//  ServerLogView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/19/24.
//

import SwiftUI

struct ServerLogView: View {
    
    @Environment(ServerController.self) private var serverController: ServerController
    
    @State var server: Server?
    
    let serverUUID: UUID?
    
    init(serverUUID: UUID?) {
        self.serverUUID = serverUUID
        server = nil
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { proxy in
                if let server {
                    Text(server.log)
                        .id("textID")
                        .monospaced()
                        .font(.footnote)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .onChange(of: server.log) { _, _ in
                            proxy.scrollTo("textID", anchor: .bottom)
                        }
                        .textSelection(.enabled)
                } else {
                    ContentUnavailableView("Unable to show server log", systemImage: "exclamationmark.triangle", description: Text("Invalid UUID received"))
                }
            }
        }
        .navigationTitle("\(server?.model ?? "Loading..."):\(String(server?.port ?? 0))")
        .onAppear {
            if let serverUUID {
                server = serverController.servers.filter({ $0.id == serverUUID }).first
            } else {
                server = nil
            }
        }
    }
}

//#Preview {
//    ServerLogView()
//}
