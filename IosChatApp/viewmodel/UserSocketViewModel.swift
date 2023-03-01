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
    @Published var groups:[Group] = [] {
        didSet {
            decryptAllMsgs()
        }
    }
    @Published var decryptedGroups: [Group] = []
    @Published var userMessage: String = ""
    @Published var navigateToCreatedGroup = false
    @Published var selectedGroup: Group? = nil
    @Published var hasError = false
    @Published var message: String = ""
    
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
                guard let selectedGroup = self.selectedGroup else { return }
                if group.groupId == selectedGroup.groupId {
                    self.selectedGroup = group
                    self.selectedGroup?.messages = self.decryptedGrpMsgs(for: group)
                }
                await self.upsertGroup(group)
            }
        }
    }
    
    func sendMessage(with groupId: String) async throws {
        if message.isEmpty {
            return
        }
        do {
            let encryptedMsg = try security.encryptMessage(message.trimmingCharacters(in: .whitespacesAndNewlines), for: groupId)
            try await userSocketService.sendMessage(text: encryptedMsg, groupId: groupId)
            self.message = ""
        } catch {
            print("couldn't encrypt msg for groupId: \(groupId)")
        }
    }
    
    
    func getUserName() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: "username") ?? ""
    }
    
    
    func fetchGroups() async throws {
        onlineStatus = .connecting
        do {
            let groups = try await userSocketService.fetchGroups()
            self.groups = groups
            //TODO: maybe this would be better if we save decrypted msgs to local
            if groups.isEmpty {
                onlineStatus = .connected
                return
            }
            onlineStatus = .updating
            
            try await self.userSocketService.openGroupSocket() { error in
                Task {
                    await self.updateUserStatus(isConnected: error == nil)
                }
                if let error = error {
                    print("ping: \(error.localizedDescription)")
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
        let request = CreateGroupRequest(
            groupName: name.trimmingCharacters(in: .whitespacesAndNewlines),
            groupDesc: desc.trimmingCharacters(in: .whitespacesAndNewlines),
            groupIcon: icon
        )
        do {
            let newGroup = try await userSocketService.createGroup(with: request)
            //generate symmetric key
            security.generateKeyForGroup(with: newGroup.groupId)
            self.selectedGroup = newGroup
            self.navigateToCreatedGroup = true
            self.hasError = false
        } catch {
            self.userMessage = error.localizedDescription
            self.hasError = true
            print("createGroup: \(error.localizedDescription)")
        }
    }
    
    func decryptedGrpMsgs(for group: Group) -> [IncomingMessage] {
        var messages: [IncomingMessage] = []
        do {
            for incoming in group.messages {
                let decipheredMsg = try security.decryptMessage(incoming.message, for: group.groupId)
                messages.append(IncomingMessage(name: incoming.name, message: decipheredMsg, id: incoming.id))
            }
        } catch {
            print("couldn't decrypt msg")
        }
        return messages
    }
    
    func decryptAllMsgs() {
        var mGroups = groups
        if mGroups.isEmpty { return }
        for index in mGroups.indices {
            var group = mGroups[index]
            group.messages = decryptedGrpMsgs(for: group)
            mGroups[index] = group
        }
        self.decryptedGroups = mGroups
    }
    
    func searchGroups(with keyword: String) async {
        do {
           let result = try await userSocketService.searchGroups(with: keyword)
        } catch {
            print("search groups: \(error.localizedDescription)")
        }
    }
}
