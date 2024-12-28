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
        FAQItem(question: "How do I add a new task?", answer: "Tap the '+' button on the main screen to create a new task. Fill out the details and tap 'Save'."),
        FAQItem(question: "How can I sync my tasks across devices?", answer: "Make sure you're using the same Apple ID on all devices. TaskSync will automatically sync your tasks."),
        FAQItem(question: "Can I search for specific tasks?", answer: "Yes! Use the search bar at the top of the search view to quickly find specific tasks."),
        //FAQItem(question: "How do I customize notifications?", answer: "Go to Settings > Notifications to set up reminders and alerts for your tasks."),
        FAQItem(question: "What should I do if my tasks aren't syncing?", answer: "Check your internet connection and ensure you're logged in to your own Apple ID on all devices. If the issue persists, try logging out and back in.")
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
                        
                        Button(action: {
                            contactSupport()
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Contact Us")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
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
