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
    @FocusState var msgFieldIsFocused: Bool
    @State private var msgChatViewPadding: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { scrollProxy in
                        LazyVStack {
                            if let group = userVm.selectedGroup {
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
                            }

                        }
                    }
                }.onTapGesture {
                    msgFieldIsFocused = false
                }
                .onChange(of: userVm.selectedGroup, perform: { group in
                    if let group = group {
                        msgChatViewPadding = group.messages.isEmpty ? 0 : 15.0
                    }else {
                        msgChatViewPadding = 0
                    }
                })
                .overlay {
                    if let group = userVm.selectedGroup {
                        if group.messages.isEmpty {
                            NoItemView(text: "no messages yet")
                        }
                    }
                }
                //MARK: chat message view
                chatMessageView
                    .padding(.top, msgChatViewPadding)
            }
            .toolbar {
                if let group = userVm.selectedGroup {
                    groupInfo(group: group)
                    ToolbarItem {
                        GroupIcon(size: 40, icon: group.groupIcon, font: .groupIconMini2)
                            .padding(.bottom, 3)
                            .padding(.trailing, -10)
                    }
                }
            }
            .embedZstack()
        }
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = userVm.selectedGroup?.messages.last {
            withAnimation(.easeOut(duration: 0.4)) {
                let index = userVm.useVmScrollPos ? userVm.groupScrollPostion : userVm.selectedGroup!.messages.firstIndex(of: lastMessage)
                proxy.scrollTo(index ?? 0, anchor: .bottom)
            }
            userVm.useVmScrollPos = false
        }
    }
    
    
    private func groupInfo(group: Group) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            NavigationLink {
                GroupInfoView(userVm: userVm)
            } label: {
                VStack(spacing: 3) {
                    Text(group.groupName)
                        .foregroundColor(.primary)
                        .font(.primaryBold2)
                    Text("\(group.users.count) members")
                        .foregroundColor(.primary.opacity(0.5))
                        .font(.secondaryText)
                }
            }
        }
    }
    
    @ViewBuilder
    private var chatMessageView: some View {
        HStack(alignment: .bottom) {
            TextField("write a message", text: $userVm.message, axis: .vertical)
                .focused($msgFieldIsFocused)
                .padding(10.0)
                .font(.secondaryMedium)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(20.0)
                .padding(.leading)
                .padding(.top, 10)
            AsyncButton {
                guard let group = userVm.selectedGroup else { return }
                await userVm.sendMessage(with: group.groupId)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .padding(6.0)
            }
            .padding(.trailing, 10)
            .disabled(userVm.message.isEmpty)
        }
        .background(Color.secondary.opacity(0.2))
    }
    
    @ViewBuilder
    private func messageItem(message: IncomingMessage, index: Int) -> some View {
        let isUser = message.name == userVm.getUserName()
        let isNotification = message.name == "" || message.name.isEmpty
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
                    }
                    VStack(alignment: .leading) {
                        if !msgIsFromSameUser {
                            Text(isUser ? "You": message.name.capitalized)
                                .font(.secondaryMedium)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .padding([.trailing, .leading, .top])
                        }
                        Text(message.message)
                            .font(.secondaryMedium)
                            .frame(minWidth: 30, minHeight: 20)
                            .padding(.top, msgIsFromSameUser ? 15: 0)
                            .padding([.bottom, .trailing, .leading])
                            .foregroundColor(isUser ? .white : userColor)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .background(isUser ? Color.accentColor : Color.clear)
                    .cornerRadius(isUser ? 25 : 0)
                    .overlay {
                        if !isUser {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.accentColor, lineWidth: 1.50)
                        }
                    }
                    .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : isNotification ? .center : .leading)
            .padding(.top, msgIsFromSameUser ? -3.0 : 10.0)
            .padding([.leading, .trailing])
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
        NavigationStack {
            GroupChatView(userVm: UserSocketViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
