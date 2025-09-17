//
//  AssistantView.swift
//  TaskSync
//
//  Created by Paul  on 9/17/25.
//

import SwiftUI

// Basic message model for the assistant
struct AssistantMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@Observable
class AssistantViewModel {
    var messages: [AssistantMessage] = [
        AssistantMessage(text: "Hi 👋, I’m your Task Assistant. What would you like me to do?", isUser: false)
    ]
    var currentInput: String = ""
    
    // Simulated AI logic – replace with your task model + AI integration
    func handleUserMessage() {
        let input = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        
        // Add user message
        messages.append(AssistantMessage(text: input, isUser: true))
        currentInput = ""
        
        // Simulated "AI response"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = self.processCommand(input)
            self.messages.append(AssistantMessage(text: response, isUser: false))
        }
    }
    
    private func processCommand(_ input: String) -> String {
        // TODO: integrate with Task model + AI API here
        if input.lowercased().contains("move") {
            return "✅ Task has been rescheduled."
        } else if input.lowercased().contains("add") {
            return "🆕 Task added to your list."
        } else if input.lowercased().contains("show") {
            return "📅 You have 3 tasks due this week."
        } else {
            return "🤔 I didn’t quite catch that. Try saying 'Add grocery shopping tomorrow at 5pm.'"
        }
    }
}

struct AssistantView: View {
    @State private var viewModel = AssistantViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.isUser { Spacer() }
                                Text(message.text)
                                    .padding(10)
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
                                if !message.isUser { Spacer() }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    TextField("Type a command...", text: $viewModel.currentInput, onCommit: {
                        viewModel.handleUserMessage()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        viewModel.handleUserMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Task Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AssistantView()
}
