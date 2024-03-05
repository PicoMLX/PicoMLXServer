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
            Section("Pico MLX Settings") {
                TextField("Chat client url scheme", text: $chatClientURL)
                Toggle("Use Conda (recommended)", isOn: $useConda)
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
