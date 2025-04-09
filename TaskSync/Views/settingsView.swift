//
//  settingsView.swift
//  TaskSync
//
//  Created by Paul  on 4/7/25.
//

import SwiftUI
import WebKit

struct settingsView: View {
    @State private var isPaywallPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("")) {
                    customPremiumBanner {
                        isPaywallPresented = true
                    }
                    .listRowInsets(EdgeInsets())
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
                
                Section(header: Text("More Apps")) {
                    customAppRow(
                        icon: Image(systemName: "questionmark.app.dashed"),
                        iconColor: .blue,
                        title: "DocMatic",
                        subtitle: "Document scanner for iPhone and iPad"
                    ) {
                        // Navigate to your app preview
                        print("Tapped DocMatic")
                    }
                    
                    customAppRow(
                        icon: Image(systemName: "questionmark.app.dashed"),
                        iconColor: .blue,
                        title: "ProLight",
                        subtitle: "Multi fuctional flashlight for iPhone"
                    ) {
                        // Navigate to your app preview
                        print("Tapped ProLight")
                    }
                    
                    customAppRow(
                        icon: Image(systemName: "questionmark.app.dashed"),
                        iconColor: .blue,
                        title: "Noel",
                        subtitle: "Christmas countdown for iPhone and iPad"
                    ) {
                        // Navigate to your app preview
                        print("Tapped Noel")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .sheet(isPresented: $isPaywallPresented) {
                // TODO: add the paywall view...
            }
        }
    }
}

#Preview {
    settingsView()
}

// MARK: Custom Row
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

// MARK: Custom App Row
struct customAppRow: View {
    let icon: Image
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .padding()
                    .background(iconColor)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    var onTap: () -> Void
    
    let features = [
        "Unlimited Tasks",
        "And 87 More Features"
    ]
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TaskSync Pro")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    ForEach(features, id: \.self) { feature in
                        Text("- \(feature)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .opacity(0.7)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Image(systemName: "checklist")
                        .font(.system(size: 70)) /// <-- Originally the size was 80
                        .foregroundStyle(.white)
                        .opacity(0.1)
                        .rotationEffect(.degrees(-20))
                        .scaleEffect(1.8) /// <-- Make it larger without affecting layout
                        .offset(x: -10, y: 20)
                        .allowsHitTesting(false) /// <-- Avoids affecting taps
                    
                    Image(systemName: "crown.fill") /// <-- Foreground icon
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle()) /// <-- Prevents default blue button style
    }
}
