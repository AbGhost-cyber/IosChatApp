//
//  ContentView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/12.
//

import SwiftUI

extension Color {
    static func random() -> Color {
        return Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ChatViewModel = ChatViewModel()
    @State private var showAddUser = false
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.receivedMessages.indices, id: \.self) { index in
                    let message = viewModel.receivedMessages[index]
                    messageItem(message: message, index: index)
                    
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showAddUser = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Funny Group: \(viewModel.users.count) people")
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
        let lastTextIndex = viewModel.receivedMessages.index(before: index)
        let msgIsFromSameUser = lastTextIndex > 0 && viewModel.receivedMessages[lastTextIndex].name == message.name
        HStack {
            if isNotification {
                Text(message.message)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            } else {
                if !isUser {
                    Circle()
                        .fill(Color.random())
                        .frame(width: 50)
                        .overlay {
                            Text(String(message.name!.first!).capitalized)
                                .font(.title2)
                        }
                        .opacity(msgIsFromSameUser ? 0 : 1)
                }
                Text(message.message)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30, minHeight: 20)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .multilineTextAlignment(.leading)
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
        .padding(msgIsFromSameUser ? .horizontal : [.top, .horizontal])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
