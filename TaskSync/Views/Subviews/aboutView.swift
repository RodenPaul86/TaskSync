//
//  aboutView.swift
//  TaskSync
//
//  Created by Paul  on 4/11/25.
//

import SwiftUI

struct aboutView: View {
    
    var body: some View {
        NavigationStack {
            List {
                Section("app info") {
                    customRow(icon: "app", firstLabel: "Application", secondLabel: Bundle.main.appName)
                    customRow(icon: "curlybraces", firstLabel: "Language", secondLabel: "Swift/SwiftUI")
                    customRow(icon: "square.on.square.dashed", firstLabel: "Version", secondLabel: Bundle.main.appVersion)
                    customRow(icon: "hammer", firstLabel: "Build", secondLabel: Bundle.main.appBuild)
                }
                
                Section(footer: Text("© 2025 Paul Roden II. All Rights Reserved.")) {
                    customRow(icon: "laptopcomputer", firstLabel: "Developer", secondLabel: "Paul Roden Jr.")
                    
                    Text("TaskSync was crafted by a single dedicated indie developer, who relies on your support to grow. \n\nTogether, we'll continuously expand and enrich the experience, ensuring you always get the most out of your subscription. \n\nThank you for being a part of this journey!")
                        .font(.subheadline)
                    
                    customRow(icon: "link", firstLabel: "My Website", secondLabel: "", url: "https://paulrodenjr.org")
                    customRow(icon: "link", firstLabel: "GitHub", secondLabel: "", url: "https://github.com/RodenPaul86")
                }
            }
            .navigationTitle("About")
        }
    }
}

#Preview {
    aboutView()
}
