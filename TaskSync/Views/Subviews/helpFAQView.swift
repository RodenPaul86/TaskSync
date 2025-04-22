//
//  HelpFAQView.swift
//  TaskSync
//
//  Created by Paul  on 4/19/25.
//

import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

// MARK: Data
struct helpFAQView: View {
    @State private var faqItems: [FAQItem] = [
        FAQItem(question: "What is TaskSync?",
                answer: "TaskSync is a simple, minimal task manager designed to help you stay organized, plan your day, and keep track of what matters — without the clutter."),
        
        FAQItem(question: "Is TaskSync free to use?",
                answer: "Yes, TaskSync is free to use. The core functionality will always remain free."),
        
        FAQItem(question: "How do I create a new task?",
                answer: "Tap the “+” button and fill in the task title, description, deadline, color and priority. You can also edit tasks later if things change."),
        
        FAQItem(question: "Can I set repeating tasks?",
                answer: "Not yet — but it’s a planned feature for a future update."),
        
        FAQItem(question: "Can I sort or filter my tasks?",
                answer: "TaskSync automatically organizes tasks by date. Search is also available to quickly find what you need."),
        
        FAQItem(question: "What’s the weekly slider at the top for?",
                answer: "That’s your quick-glance timeline! Swipe through the week and see your tasks for each day."),
        
        /*
        FAQItem(question: "Can I change the theme or app icon?",
                answer: "Yes! Head to Settings to switch between light, dark, or auto themes, and pick your favorite app icon."),
         */
        
        FAQItem(question: "How does syncing work in TaskSync?",
                answer: "TaskSync automatically syncs your tasks across devices using iCloud (if enabled). Just sign in with the same Apple ID."),
        
        FAQItem(question: "Do I need an internet connection to use TaskSync?",
                answer: "Nope! TaskSync works offline. When you’re back online, it syncs automatically."),
        
        FAQItem(question: "Are my tasks private?",
                answer: "Yes. Your data is stored locally and securely. We never collect or share your data."),
        
        FAQItem(question: "Can I lock the app with Face ID or Touch ID?",
                answer: "Not yet, but biometric lock support is coming soon."),
        
        FAQItem(question: "How do I delete a task?",
                answer: "Long press on a task and select Delete. Deleted tasks are gone for good (for now — recovery features are on the roadmap)."),
        
        FAQItem(question: "Can I recover deleted tasks?",
                answer: "Currently, no. Once deleted, a task is permanently removed. We’re working on adding a trash or undo feature."),
        
        FAQItem(question: "I found a bug / have feedback. What should I do?",
                answer: "We’d love to hear from you! Reach out via the “Contact Support” button in Settings or email us at support@paulrodenjr.org.")
    ]
    
    // MARK: Main View
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("")) {
                        ForEach($faqItems) { $item in
                            FAQRow(item: $item)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .safeAreaPadding(.bottom, 60)
            }
            .navigationTitle("FAQS")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: Custom Row
struct FAQRow: View {
    @Binding var item: FAQItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.snappy) {
                    item.isExpanded.toggle()
                    HapticManager.shared.notify(.impact(.light))
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: item.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if item.isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    helpFAQView()
}
