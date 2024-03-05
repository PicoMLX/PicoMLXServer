//
//  SetupView.swift
//  PicoMLXServer
//
//  Created by Ronald Mannak on 3/13/24.
//

import SwiftUI
import SplitView

struct SetupView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL

    @State var platforms: [PlatformViewModel] = [PlatformViewModel]()
    @State var error: Error? = nil
    @State var showError = false
    @State var showOpenURLSheet = false
    @State var url: URL? = nil
    @State var consoleLog = ""
    
    private var columns: [GridItem] = [
            GridItem(.fixed(75), spacing: 16), // Name
            GridItem(.fixed(50), spacing: 16), // Version installed
            GridItem(.fixed(200), spacing: 16), // Path
            GridItem(.fixed(100), spacing: 16), // State
            GridItem(.fixed(100), spacing: 16), // Button
        ]
    
    init() {
        do {
            let platforms = try Platform.loadPlatforms()
            _platforms = State(initialValue: platforms.map { PlatformViewModel(platform: $0) })
            print(platforms)
            print(self.platforms)
        } catch {
            _error = State(initialValue: error)
        }
    }
    
    var body: some View {
        VSplit(top: {
            if !platforms.isEmpty {
                
                GroupBox {
                    ScrollView() {
                        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                            ForEach(platforms) { platform in
                                Section(header: Text(platform.name).font(.body)) {
                                    ForEach(platform.dependencies) { dependency in
                                        
                                        GridRow {
                                            Text(dependency.name.capitalized)
                                                .fontWeight(.bold)
                                                .frame(width: 75)
                                            Text(dependency.versionInstalled)
                                                .frame(width: 50)
                                            Text(dependency.path ?? "")
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                                .foregroundStyle(Color.secondary)
                                            Label(dependency.state.description, systemImage: dependency.state.systemImage)
                                                .frame(width: 100)
                                            Button(dependency.state.buttonLabel) {
                                                do {
                                                    if let url = try dependency.action() {
                                                        self.url = url
                                                        self.showOpenURLSheet = true
                                                    }
                                                } catch {
                                                    self.error = error
                                                    showError = true
                                                    
                                                }
                                            }
                                            .disabled(dependency.state.disableButton)
                                            .controlSize(.small)
                                            .gridColumnAlignment(.trailing)
                                        }
                                        Divider()
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                } label: {
                    Text("Install MLX dependencies")
                }
                .padding(.bottom, 4)
                
            } else {                
                ContentUnavailableView("Unable to load Dependencies.plist", systemImage: "exclamationmark.triangle", description: Text(error?.localizedDescription ?? "Unknown error occurred"))
            }
            
        }, bottom: {
            ScrollView(.vertical) {
                ScrollViewReader { proxy in
                    Text(consoleLog)
                        .id("textID")
                        .monospaced()
                        .font(.footnote)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .onChange(of: consoleLog) { _, _ in
                            proxy.scrollTo("textID", anchor: .bottom)
                        }
                        .textSelection(.enabled)
                }
            }
        })
        .fraction(0.75)
        .styling(color: Color.gray.opacity(0.25), inset: 0, visibleThickness: 2)
        .padding()
        .onAppear {
            for platform in self.platforms {
                for dependency in platform.dependencies {
                    dependency.output = { string in
                        consoleLog.append(string)
                    }
                    dependency.setInitialState()
                }
            }
        }
        .alert(error?.localizedDescription ?? "Unknown error occurred", isPresented: $showError) {}
        .confirmationDialog("Pico MLX Server cannot install this dependency. Please install manually", isPresented: $showOpenURLSheet, actions: {
            Button("Open") {
                openURL(url!)
            }.disabled(url == nil)
            Button("Cancel", role: .cancel) { }
        })
        .onDisappear {
            NSApplication.hide()
        }
    }
}

#Preview {
    SetupView()
}
