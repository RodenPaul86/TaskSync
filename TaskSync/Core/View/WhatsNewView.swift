//
//  WhatsNewView.swift
//  TaskSync
//
//  Created by Paul  on 12/31/24.
//

import SwiftUI

struct WhatsNewView: View {
    let updates: [Update] = [
        Update(
            title: "Better Mirror",
            version: "v1.2.3",
            date: "December 2024",
            description: "This update adds sharing to the Mirror tool. When using the selfie view, tap the camera button to take a snapshot, then tap the share button to send it to a friend, post it to the group thread, or save it to your photo library.\n\nThis version of TaskSync also allows you to increase the number of items shown in the list widgets.",
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
    WhatsNewView()
}
