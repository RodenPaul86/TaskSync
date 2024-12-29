//
//  HelpFAQView.swift
//  TaskSync
//
//  Created by Paul  on 12/28/24.
//

import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

struct HelpFAQView: View {
    @State private var faqItems: [FAQItem] = [
        FAQItem(question: "How do I add a new task?",
                answer: "To add a new task, tap the “+” button on the main screen. Enter the task title, description (optional), set a due date. Once you’re done, tap “Create” to add the task to your list."),
        
        FAQItem(question: "How do I mark a task as complete?",
                answer: "Simply long press the task or tap the checkmark on the task. This will mark the task as “Completed”."),
        
        FAQItem(question: "How can I sync my tasks across devices?",
                answer: "Ensure you’re logged into the same Apple account across all devices. TaskSync will automatically sync your tasks when you’re connected to the internet."),
        
        FAQItem(question: "Can I set reminders for my tasks?",
                answer: "Yes, you can set reminders when creating or editing a task. Choose the time and frequency of the reminder, and you’ll receive a notification when it’s time to complete the task."),
        
        FAQItem(question: "How can I search for specific tasks?",
                answer: "Use the search bar at the top of the search view to quickly find specific tasks."),
        
        FAQItem(question: "What should I do if my tasks aren't syncing?",
                answer: "Check your internet connection and ensure you're logged in to your own Apple account on all devices. If the issue persists, try logging out and back in."),
        
        //FAQItem(question: "Does TaskSync support recurring tasks?", answer: "Yes, you can set tasks to repeat daily, weekly, monthly, or on a custom schedule when creating or editing a task."),
        
        FAQItem(question: "How do I customize the app’s appearance?",
                answer: "You can toggle between light and dark mode in the app settings. More themes and color options are planned for future updates."),
        
        FAQItem(question: "Can I recover deleted tasks?",
                answer: "Currently, deleted tasks cannot be recovered. Please double-check before deleting any tasks."),
        
        FAQItem(question: "Is my data secure in TaskSync?",
                answer: "Yes, your data is stored securely using iCloud. Only you have access to your tasks and data."),
        
        FAQItem(question: "How do I request new features?",
                answer: "We welcome feedback! Use the ''eMail Support'' option below to share your ideas and requests.")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Frequently Asked Questions").font(.headline)) {
                        ForEach($faqItems) { $item in
                            FAQRow(item: $item)
                        }
                    }
                    Section(header: Text("Need more help?").font(.headline)) {
                        /*
                        Button(action: {
                            print("ChatBot tapped")
                        }) {
                            HStack {
                                Image(systemName: "headset")
                                Text("Help Desk")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                        }
                        */
                        Button(action: {
                            contactSupport()
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("eMail Support")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .safeAreaPadding(.bottom, 60)
            }
            .navigationTitle("Help & FAQ")
        }
    }
    
    private func contactSupport() {
        print("Contact support tapped")
    }
}

struct FAQRow: View {
    @Binding var item: FAQItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    item.isExpanded.toggle()
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

struct HelpFAQView_Previews: PreviewProvider {
    static var previews: some View {
        HelpFAQView()
    }
}
