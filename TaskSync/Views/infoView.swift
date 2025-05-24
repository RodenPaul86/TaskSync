//
//  infoView.swift
//  TaskSync
//
//  Created by Paul  on 4/2/25.
//

import SwiftUI

struct infoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSubModel: appSubscriptionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Indicator Guide")
                    .font(.title2.bold())
                    .padding(.bottom, 5)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color(.lightGray))
                        .opacity(0.25)
                }
            }
            .hSpacing(.trailing)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .red, title: "Past Hour", description: "Tasks that were scheduled in the past hour.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .blue, title: "Current Hour", description: "The task that is scheduled for the current hour.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .green, title: "Completed", description: "Tasks that have been marked as completed.")
            }
            .padding([.top, .horizontal], 5)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(color: .black, title: "Upcoming", description: "Tasks scheduled for future hours.")
            }
            .padding([.top, .horizontal], 5)
            
            if appSubModel.isSubscriptionActive {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .foregroundStyle(.gray)
                            .frame(width: 10, height: 10)
                            .padding(4)
                        
                        VStack(alignment: .leading) {
                            Text("Recurring Events")
                                .font(.headline)
                            
                            Text("This icon indicates that the event repeats on a regular schedule, such as daily, weekly, or monthly.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding([.top, .horizontal], 5)
            }
            
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
