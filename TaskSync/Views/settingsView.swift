//
//  settingsView.swift
//  TaskSync
//
//  Created by Paul  on 4/7/25.
//

import SwiftUI
import WebKit

struct settingsView: View {
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("")) {
                    customPremiumBanner()
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section(header: Text("Costomization")) {
                    customRow(icon: "paintbrush", firstLabel: "Appearance", secondLabel: "") {
                        //showPickerView.toggle()
                    }
                    
                    customRow(icon: "questionmark.app.dashed", firstLabel: "Alternate Icons", secondLabel: "") {
                        
                    }
                    
                    customRow(icon: "", firstLabel: "", secondLabel: "") {
                        
                    }
                }
                
                Section(header: Text("Contact & Support")) {
                    customRow(icon: "", firstLabel: "Frequently Asked Questions", secondLabel: "")
                    customRow(icon: "", firstLabel: "Get Help", secondLabel: "")
                }
                
                Section(header: Text("Info")) {
                    customRow(icon: "", firstLabel: "Colophon", secondLabel: "")
                    customRow(icon: "", firstLabel: "Acknowledgements", secondLabel: "")
                    customRow(icon: "", firstLabel: "Privacy Policy", secondLabel: "")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
        }
    }
}

#Preview {
    settingsView()
}

struct customRow: View {
    var icon: String
    var firstLabel: String
    var firstLabelColor: Color = .gray
    var secondLabel: String
    var action: (() -> Void)? = nil  /// <-- Optional action
    var destination: AnyView? = nil  /// <-- Optional navigation
    var url: String? = nil           /// <-- Optional URL
    
    @State private var isNavigating = false
    
    var body: some View {
        if let urlString = url {
            NavigationLink {
                webView(url: urlString)
                    .edgesIgnoringSafeArea(.all)
                    .navigationTitle(firstLabel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if let link = URL(string: urlString) {
                                Link(destination: link) {
                                    Image(systemName: "safari")
                                }
                            }
                        }
                    }
            } label: {
                rowContent(showChevron: false)
            }
            .buttonStyle(.plain)
        } else if let destination = destination {
            NavigationLink {
                destination
            } label: {
                rowContent(showChevron: false)
            }
            .buttonStyle(.plain) // Keeps it looking like a row
        } else {
            rowContent(showChevron: action != nil)
                .onTapGesture {
                    action?()
                }
        }
    }
    
    private func rowContent(showChevron: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(.blue.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(firstLabel)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .imageScale(.small)
                    .foregroundColor(Color.init(uiColor: .systemGray3))
            } else {
                Text(secondLabel)
                    .font(.headline)
                    .foregroundStyle((action == nil && destination == nil && url == nil) ? .gray : .primary)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func isWebsite(_ urlString: String) -> Bool {
        return urlString.hasPrefix("http") // Simple check for URLs
    }
}

struct webView: UIViewRepresentable {
    var url: String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
    }
}

// MARK: Custom Banner
struct customPremiumBanner: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "laurel.leading")
                Text("TaskSync Pro")
                Image(systemName: "laurel.trailing")
            }
            .font(.title.bold())
            .foregroundColor(.gray)
            
            Button(action: {}) { // TODO: Add Paywall
                Text("See What You Get")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.gradient)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
        }
        .padding()
    }
}
