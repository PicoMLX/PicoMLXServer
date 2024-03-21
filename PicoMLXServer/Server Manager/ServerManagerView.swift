//
//  ServerManagerView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/18/24.
//

import SwiftUI

struct ServerManagerView: View {
    
    @Environment(\.openURL) var openURL
    @Environment(ServerController.self) private var serverController
    
    @State private var model: String = "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX"
    @State private var port: Int = 8080
    @State private var showCustomModelTextField = false
    @State private var showError = false
    @State private var error: Error? = nil
    
    // TODO: https://x.com/ronaldmannak/status/1770123553666711778?s=20
    let models = [
        "mlx-community/Nous-Hermes-2-Mistral-7B-DPO-4bit-MLX",
        "mlx-community/NeuralBeagle14-7B-4bit-mlx",
        "mlx-community/Mistral-7B-v0.1-hf-4bit-mlx",
        "mlx-community/starcoder2-15b-4bit",
        "mlx-community/quantized-gemma-2b-it",
        "mlx-community/quantized-gemma-2b",
        "mlx-community/Mixtral-8x7B-v0.1-hf-4bit-mlx",
        "mlx-community/Llama-2-7b-chat-mlx",        
    ]
    
    var body: some View {
        VStack {
            
            ServerListView(showError: $showError, error: $error)
                .padding()
                .frame(maxWidth: .infinity)

            GroupBox {
                HStack {
                    GroupBox {
                        HStack {
                            Text("Model:")
                            TextField("Model: ", text: $model)
                            Menu {
                                ForEach(models, id: \.self) { model in
                                    Button(model) { self.model = model }
                                }
                            } label: {
                                EmptyView()
                            }
                            .frame(width: 15)
                            .menuStyle(.borderlessButton)
                        }
                    }
                    
                    Text("Port:")
                    TextField("Port", value: $port, format: .number.grouping(.never)) // { Text("Port:") }
                        .frame(width: 100)
                    
                    Button("Create") {
                        do {
                            try serverController.addServer(model: model, port: port)
                        } catch {
                            self.error = error
                        }
                    }
                    .keyboardShortcut(.defaultAction)                    
                    //                    .alert(isPresented: $showError, error: error, actions: {
                    .alert(error?.localizedDescription ?? "Unknown error occurred", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Button {
                        openURL(URL(string: "https://huggingface.co/mlx-community")!)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .padding(.trailing)
                    .buttonStyle(.plain)
                    .controlSize(.small)
                }
                .padding(4)
                
            } label: {
                Label("Create New Server", systemImage: "server.rack")
            }
            .padding()

        }
    }
}

#Preview {
    ServerManagerView()
}
