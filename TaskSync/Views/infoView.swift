//
//  infoView.swift
//  TaskSync
//
//  Created by Paul  on 4/2/25.
//

import SwiftUI

struct infoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Colors Guide")
                    .font(.title2.bold())
                    .padding(.bottom, 5)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color(.systemGray6))
                }
            }
            .hSpacing(.trailing)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .red, title: "Past Hour Tasks", description: "Tasks that were scheduled in the past hour.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .blue, title: "Current Hour Task", description: "The task that is scheduled for the current hour.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .green, title: "Completed Task", description: "Tasks that have been marked as completed.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .black, title: "Upcoming Tasks", description: "Tasks scheduled for future hours.")
            }
            .padding([.top, .horizontal], 5)
            
            Spacer(minLength: 0)
        }
        .padding(15)
    }
}

struct InfoRow: View {
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: Circle())
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    infoView()
        .vSpacing(.bottom)
}
