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
    
    init(userSocketService: UserSocketService = UserSocketImpl()) {
        self.userSocketService = userSocketService
    }
    
    private func updateUserStatus(isConnected: Bool) async {
        await MainActor.run {
            self.onlineStatus = isConnected ? .connected : .disconnected
        }
    }
    private func upsertGroup(_ group: Group) async {
        await MainActor.run {
            var mGroups = self.groups
            if let index = mGroups.firstIndex(where: {$0.groupId == group.groupId}) {
                mGroups[index] = group
            } else {
                mGroups.append(group)
            }
            self.groups = mGroups
        }
    }
    
    func listenForMessages() async {
        await userSocketService.onGroupChange { group in
            Task {
              await self.upsertGroup(group)
            }
        }
    }
    
    
    
    func fetchGroups() async throws {
        onlineStatus = .connecting
        do {
            let groups = try await userSocketService.fetchGroups()
            self.groups = groups
            if groups.isEmpty {
                onlineStatus = .connected
                return
            }
            onlineStatus = .updating
            
            await groups.concurrentForEach { group in
                try await self.userSocketService.openGroupSocket(with: group.groupId) { error in
                    Task {
                        await self.updateUserStatus(isConnected: error == nil)
                    }
                    if let error = error {
                        print("ping: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("fetchGroups error : \(error.localizedDescription)")
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
