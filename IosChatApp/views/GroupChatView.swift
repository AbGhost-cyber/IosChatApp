//
//  GroupChatView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/25.
//

import SwiftUI

struct GroupChatView: View {
    @ObservedObject var userVm: UserSocketViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.primary.opacity(0.1))
                .ignoresSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { scrollProxy in
                        if let group = userVm.selectedGroup {
                            LazyVStack {
                                ForEach(group.messages.indices, id: \.self) { index in
                                    let message = group.messages[index]
                                    messageItem(message: message, index: index)
                                }
                                .onChange(of: group.messages.count) { newValue in
                                    scrollToLastMessage(proxy: scrollProxy)
                                }
                                .onAppear {
                                    scrollToLastMessage(proxy: scrollProxy)
                                }
                            }.overlay {
                                if group.messages.isEmpty {
                                    NoItemView(text: "no messages yet")
                                }
                            }
                        }
                    }
                }
                //MARK: chat message view
                chatMessageView
                    .padding()
            }
            .toolbar {
                if let group = userVm.selectedGroup {
                    
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 3) {
                            Text(group.groupName)
                                .foregroundColor(.primary)
                                .font(.primaryBold2)
                            Text("\(group.users.count) members")
                                .foregroundColor(.primary.opacity(0.5))
                                .font(.secondaryText)
                        }
                    }
                    
                    ToolbarItem {
                        GroupIcon(size: 45, icon: group.groupIcon, font: .groupIconMini2)
                    }
                }
            }

        }
    }
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = userVm.selectedGroup?.messages.last {
            withAnimation(.easeOut(duration: 0.4)) {
                let index = userVm.selectedGroup!.messages.firstIndex(of: lastMessage)
                proxy.scrollTo(index ?? 0, anchor: .bottom)
            }
        }
    }
    
    private var chatMessageView: some View {
        HStack {
            TextField("write a message", text: $userVm.message)
                .padding(10.0)
                .font(.secondaryMedium)
                .background(Color.secondary.opacity(0.2))
            AsyncButton {
                guard let group = userVm.selectedGroup else { return }
                try await userVm.sendMessage(with: group.groupId)
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .padding(6.0)
            }
            .disabled(userVm.message.isEmpty)

        }
    }
    
    @ViewBuilder
    private func messageItem(message: IncomingMessage, index: Int) -> some View {
        let isUser = message.name == userVm.getUserName()
        let isNotification = message.name == ""
        let messages = userVm.selectedGroup?.messages ?? []
        if !messages.isEmpty {
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
                                Text(String(message.name.first!).capitalized)
                                    .font(.primaryBold)
                            }
                            .opacity(msgIsFromSameUser ? 0 : 1)
                    }
                    VStack(alignment: isUser ? .trailing : .leading, spacing: 10) {
                        if !msgIsFromSameUser {
                            Text(isUser ? "you" : message.name)
                                .font(.secondaryText)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .fontWeight(.thin)
                                .offset(x: !isUser ? 10: -10)
                        }
                        Text(message.message)
                            .font(.secondaryMedium)
                            .frame(minWidth: 30, minHeight: 20)
                            .padding()
                            .background(isUser ? Color.accentColor : Color.clear)
                            .foregroundColor(isUser ? .white : userColor)
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
                                Text(String(message.name.first!).capitalized)
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
    
    private var userColor: Color {
        if colorScheme == .dark {
            return .white
        }
        return .black
    }
}

struct GroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatView(userVm: UserSocketViewModel())
    }
}
