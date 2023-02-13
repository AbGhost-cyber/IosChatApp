//
//  ContentView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/12.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: ChatViewModel = ChatViewModel()
    @State private var showAddUser = false
    let list = Array(repeating: Message(name: " Ab", message: "Hi there, good morning", id: UUID().uuidString), count: 1)
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.receivedMessages.indices, id: \.self) { index in
                    let message = viewModel.receivedMessages[index]
                    messageItem(message: message, index: index)
                    
                }
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem {
                    Button {
                        showAddUser = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Funny Group: \(viewModel.userCount) people")
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("Enter a message", text: $viewModel.userMessage)
                        Button {
                            Task {
                                try await viewModel.sendMessage()
                            }
                        } label: {
                            Image(systemName: "paperplane.circle.fill")
                        }
                        
                    }
                }
            }
            .alert("wanna join chat?", isPresented: $showAddUser) {
                TextField("input your username", text: $viewModel.currentUserName)
                Button("Join") {
                    Task {
                        try await viewModel.initSession()
                    }
                }
            }
            //            .task {
            //                do {
            //                    try await viewModel.observeMessages()
            //                } catch {
            //                    print("couldnt")
            //                }
            //            }
        }
    }
    
    @ViewBuilder
    private func messageItem(message: Message, index: Int) -> some View {
        let isUser = message.name == viewModel.currentUserName
        let isNotification = message.name == nil
        let messages = viewModel.receivedMessages
        let lastTextIndex = messages.index(before: index)
        let msgIsFromSameUser = lastTextIndex != -1  && messages[lastTextIndex].name == message.name
        HStack {
            if isNotification {
                Text(message.message)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.bottom)
            } else {
                if !isUser {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 50)
                        .overlay {
                            Text(String(message.name!.first!).capitalized)
                                .font(.title2)
                        }
                        .opacity(msgIsFromSameUser ? 0 : 1)
                }
                VStack(alignment: isUser ? .trailing : .leading, spacing: 10) {
                    if let name = message.name {
                        if !msgIsFromSameUser {
                            Text(isUser ? "you" : name)
                                .font(.subheadline)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .fontWeight(.thin)
                                .offset(x: !isUser ? 10: -10)
                        }
                    }
                    Text(message.message)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30, minHeight: 20)
                        .padding()
                        .background(isUser ? Color.accentColor : Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(isUser ? 25 : 0)
                        .multilineTextAlignment(.leading)
                        .overlay {
                            if !isUser {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.accentColor, lineWidth: 1.50)
                            }
                        }
                }
                
                if isUser {
                    Circle()
                        .fill(Color.teal)
                        .frame(width: 50)
                        .overlay {
                            Text(String(message.name!.first!).capitalized)
                                .font(.title2)
                        }
                        .opacity(msgIsFromSameUser ? 0 : 1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : isNotification ? .center : .leading)
        .padding([.top, .horizontal], msgIsFromSameUser ? -3: 30)
        .padding(.trailing, msgIsFromSameUser ? 0: 10)
        .padding(.leading, msgIsFromSameUser ? 10: 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
