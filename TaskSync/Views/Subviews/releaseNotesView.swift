//
//  releaseNotesView.swift
//  TaskSync
//
//  Created by Paul  on 5/24/25.
//

import SwiftUI

struct releaseNotesView: View {
    let updates: [appUpdate] = [
        appUpdate(title: "TaskSync 2.0",
                  version: "2.0.0",
                  date: "September, 2025",
                  description: "TaskSync is now ready for iOS 26!",
                  imageName: "",
                  features: ["Optimized for iOS 26.",
                             "Ai Summarized infomation about your day."
                            ],
                  bugFixes: [
                    "Minor bug fixes and improvements."
                  ]),
        
        appUpdate(title: "TaskSync is Here!",
                  version: "1.0.0",
                  date: "February, 2025",
                  description: """
We’re excited to introduce TaskSync — your all-in-one task and productivity companion!

With this first release, you can create, manage, and organize your tasks effortlessly, helping you stay focused and in control.

TaskSync is built to simplify your day and streamline your workflow — no matter where life takes you.
""",
                  imageName: "",
                  features: nil,
                  bugFixes: nil)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(updates, id: \.id) { update in
                    UpdateCard(update: update)
                }
            }
            .padding()
            .safeAreaPadding(.bottom, 60)
            .navigationTitle("Release Notes")
        }
    }
}

struct UpdateCard: View {
    let update: appUpdate
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack(alignment: .leading, spacing: 12) {
                // Centered Title and Version/Date
                VStack(spacing: 4) {
                    if !update.title.isEmpty {
                        Text(update.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("v\(update.version) • \(update.date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // Description
                if !update.description.isEmpty {
                    Text(update.description)
                        .font(.body)
                }
                
                // Centered Optional image
                VStack(spacing: 4) {
                    if !update.imageName.isEmpty {
                        Image(update.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .cornerRadius(12)
                            .padding(.bottom, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // Features
                if let features = update.features, !features.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's New")
                            .font(.headline)
                        ForEach(features, id: \.self) { feature in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(feature)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // Bug Fixes
                if let bugFixes = update.bugFixes, !bugFixes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bug Fixes")
                            .font(.headline)
                        ForEach(bugFixes, id: \.self) { fix in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(fix)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color("BGTile"))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                // Centered Title and Version/Date
                VStack(spacing: 4) {
                    if !update.title.isEmpty {
                        Text(update.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("v\(update.version) • \(update.date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // Description
                if !update.description.isEmpty {
                    Text(update.description)
                        .font(.body)
                }
                
                // Centered Optional image
                VStack(spacing: 4) {
                    if !update.imageName.isEmpty {
                        Image(update.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .cornerRadius(12)
                            .padding(.bottom, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                // Features
                if let features = update.features, !features.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's New")
                            .font(.headline)
                        ForEach(features, id: \.self) { feature in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(feature)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // Bug Fixes
                if let bugFixes = update.bugFixes, !bugFixes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bug Fixes")
                            .font(.headline)
                        ForEach(bugFixes, id: \.self) { fix in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(fix)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color("BGTile"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: Data Model
struct appUpdate: Identifiable {
    let id = UUID()
    let title: String
    let version: String
    let date: String
    let description: String
    let imageName: String
    let features: [String]?
    let bugFixes: [String]?
}

// MARK: Preview
#Preview {
    releaseNotesView()
}
