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
    //TODO: make sure that the new user can never receive messages earlier than the date he joined
    @Published var groups:[Group] = []
    @Published var userMessage: String = ""
    @Published var navigateToCreatedGroup = false
    @Published var createdGroup: Group? = nil
    
    private let userSocketService: UserSocketService
    private let security: Security
    
    init(userSocketService: UserSocketService = UserSocketImpl(), security: Security = SecurityImpl()) {
        self.userSocketService = userSocketService
        self.security = security
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
        print("create group")
        let isValid = !name.isEmpty && !desc.isEmpty && !icon.isEmpty
        if !isValid {
            self.userMessage = "required fields cannot be empty"
            return
        }
        let request = CreateGroupRequest(groupName: name, groupDesc: desc, groupIcon: icon)
        do {
            let newGroup = try await userSocketService.createGroup(with: request)
            security.generateKeyForGroup(with: newGroup.groupId)
            //try await fetchGroups()
            self.createdGroup = newGroup
            self.navigateToCreatedGroup = true
        } catch {
            print("createGroup: \(error.localizedDescription)")
        }
    }
    
    func getGroupMsgs(for groupId: String) -> [IncomingMessage] {
        var messages: [IncomingMessage] = []
        if let group = groups.first(where: {$0.groupId == groupId}) {
            do {
              messages = try group.messages.map { message in
                    IncomingMessage (
                        name: message.name,
                        message: try security.decryptMessage(message.message, for: groupId),
                        id: groupId )
                }
            } catch {
                print("couldn't decrypt msg")
            }
        }
        return messages
    }
    
}
