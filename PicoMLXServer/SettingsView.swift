//
//  SettingsView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/4/24.
//
// Download models, see: https://github.com/huggingface/swift-chat

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("chatClientURL") private var chatClientURL = "pico://"
    @AppStorage("useConda") private var useConda = true
    
    var body: some View {
        
        Form {            
            Section {
                TextField("Chat client url scheme", text: $chatClientURL)
                Divider()
                Toggle("Use Conda (recommended)", isOn: $useConda)
                Divider()
                
            } header: {
                Text("Pico MLX Settings")
            } footer: {
                if let version = Bundle.main.releaseVersionNumber,
                    let build = Bundle.main.buildVersionNumber {
                        Text("Version \(version) (\(build))")
                            .foregroundColor(.gray)
                            .font(.footnote)
                } else {
                    EmptyView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
