//
//  WhatsNewView.swift
//  TaskSync
//
//  Created by Paul  on 12/31/24.
//

import SwiftUI

struct whatsNewView: View {
    let updates: [Update] = [
        Update(
            title: "TaskSync is Here!",
            version: "v1.0.0",
            date: "January 2025",
            description: """
            We're excited to introduce TaskSync, the ultimate tool for managing your tasks! With this first release, you can easily create, organize, and track tasks across all your devices. Stay on top of your schedule with intuitive reminders and due dates. TaskSync is designed to help you stay productive and organized, wherever you go.
            """,
            imageName: "exampleImage" // Replace with actual image name
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(updates, id: \.id) { update in
                        UpdateCard(update: update)
                    }
                }
                .padding()
            }
            .navigationTitle("What's New")
            .navigationBarTitleDisplayMode(.automatic)
            .safeAreaPadding(.bottom, 60)
        }
    }
}

struct UpdateCard: View {
    let update: Update

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Title and version info
            Text(update.title)
                .font(.title2)
                .fontWeight(.bold)
            Text("\(update.version)  •  \(update.date)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                // Description
                Text(update.description)
                    .font(.body)
                    .foregroundColor(.primary)
                
                /*
                // Optional image
                if let imageName = update.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                }
                 */
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Data Model
struct Update: Identifiable {
    let id = UUID()
    let title: String
    let version: String
    let date: String
    let description: String
    let imageName: String? // Optional for updates without images
}

// Preview
#Preview {
    whatsNewView()
}
