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
    
    func connectToServer() async throws {
        onlineStatus = .connecting
        do {
            onlineStatus = .updating
            try await fetchGroups()
            try await userSocketService.connectToServer { error in
                Task {
                    await self.updateUserStatus(isConnected: error == nil)
                }
            }
        } catch {
            print("connectToServer: \(error.localizedDescription)")
        }
    }
    
  func fetchGroups() async throws {
        do {
           let groups = try await userSocketService.fetchGroups()
            self.groups = groups
        } catch {
            print("fetchGroups: \(error.localizedDescription)")
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
