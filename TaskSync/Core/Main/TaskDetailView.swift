//
//  TestView.swift
//  TaskSync
//
//  Created by Paul  on 1/11/25.
//

import SwiftUI
import CoreData

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Title Section
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("01/11/2025, 10:00 PM")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("No Title")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15)).bold()
                            .foregroundColor(Color(.systemGray6))
                            .padding(6)
                            .background(.gray)
                            .clipShape(Circle())
                    }
                }
            }
            
            Divider()
            
            // Button Section
            HStack(spacing: 16) {
                Button(action: {
                    
                }, label: {
                    ActionButton(icon: "trash.fill", label: "Delete", color: .red)
                })
                
                Button(action: {
                    
                }, label: {
                    ActionButton(icon: "doc.on.doc.fill", label: "Duplicate", color: .black)
                })
                
                Button(action: {
                    
                }, label: {
                    ActionButton(icon: "checkmark.circle.fill", label: "Complete", color: .black)
                })
            }
            
            // Edit Task Button
            Button(action: {
                // Edit task action
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Edit Task")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(label)
                .font(.footnote).bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures uniform size
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    TaskDetailView()
}
