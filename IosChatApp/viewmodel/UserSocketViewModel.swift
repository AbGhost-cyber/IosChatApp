//
//  UserSocketViewModel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation

enum ConnState {
    case connecting
    case connected
    case updating
    case disconnected
    
    var text: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .connected:
            return "Chats"
        case .disconnected:
            return "Disconnected"
        case .updating:
            return "Updating"
        }
    }
}

@MainActor
class UserSocketViewModel: ObservableObject {
    
    @Published var onlineStatus: ConnState = .disconnected
    @Published var groups:[Group] = []
    @Published var userMessage: String = ""
    
    private let userSocketService: UserSocketService
    private let chatService: ChatService
    
    init(userSocketService: UserSocketService = UserSocketImpl(),
         chatService: ChatService = ChatServiceImpl()) {
        self.userSocketService = userSocketService
        self.chatService = chatService
    }
    
    private func updateUserStatus(isConnected: Bool) async {
        await MainActor.run {
            self.onlineStatus = isConnected ? .connected : .disconnected
        }
    }
    
    func connectToServer() async throws {
        onlineStatus = .connecting
        do {
             try await fetchGroups()
            onlineStatus = .connected
//            try await userSocketService.connectToServer { error in
//                Task {
//                    try await self.fetchGroups()
//                }
//                Task {
//                    await self.updateUserStatus(isConnected: error == nil)
//                }
//            }
        } catch {
            print("connectToServer: \(error.localizedDescription)")
            onlineStatus = .disconnected
        }
    }
    
    func fetchGroups() async throws {
        do {
            let groups = try await userSocketService.fetchGroups()
            self.groups = groups
            if groups.isEmpty { return }
            self.groups.forEach { group in
                Task {
                    do {
                        try await self.chatService.openGroupSocket(with: group.groupId)
                    } catch {
                        print("fishy: \(error.localizedDescription)")
                    }
                }
            }
//            await groups.concurrentForEach { group in
//                try await self.chatService.openGroupSocket(with: group.groupId)
//            }
            print("called")
        } catch {
            print("fetchGroups: \(error.localizedDescription)")
            onlineStatus = .disconnected
        }
    }
    
    func createGroup(name: String, desc: String, icon: String)  async throws {
        let isValid = !name.isEmpty && !desc.isEmpty && !icon.isEmpty
        if !isValid {
            self.userMessage = "required fields cannot be empty"
            return
        }
        let request = CreateGroupRequest(groupName: name, groupDesc: desc, groupIcon: icon)
        do {
            try await userSocketService.createGroup(with: request)
            try await fetchGroups()
        } catch {
            print("createGroup: \(error.localizedDescription)")
        }
    }
    
}
