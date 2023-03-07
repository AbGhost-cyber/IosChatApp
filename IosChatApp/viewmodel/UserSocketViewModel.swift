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
            return "Connecting..."
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
    private var groups:[Group] = [] {
        didSet {
            decryptAllMsgs()
        }
    }
    @Published var decryptedGroups: [Group] = []
    @Published var userMessage: String = ""
    @Published var navigateToCreatedGroup = false
    var groupScrollPostion: Int = 0
    var useVmScrollPos: Bool = false
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
    
    func handleAdminGroupRequest(with action: RequestAction, joinReq: JoinRequestIncoming) async -> [JoinRequestIncoming] {
        guard let group = selectedGroup else { return [] }
        do {
            let encryptedGroupKey = try security.exchangeGroupkeyAsymmetric(with: group.groupId, and: joinReq.publicKey)
            let adminRes = action == .reject ? nil : GroupAcceptResponse(username: joinReq.username, groupId: group.groupId, publicKey: encryptedGroupKey)
            
            let request = try await userSocketService.handleAdminGroupRequest(
                groupId: group.groupId,
                with: adminRes,
                username: joinReq.username,
                action: action.rawValue
            )
            return request
        } catch SecurityException.userPkeyEmpty {
            setErrorWithMsg("operation unsuccessful")
            print("operation can process due to user's pkey being empty")
        } catch SecurityException.adminKeyNotFound {
            setErrorWithMsg("admin key not found")
        } catch {
            setErrorWithMsg(error.localizedDescription)
            print("admin group request handle: \(error.localizedDescription)")
        }
        return []
    }
    
    
    func getGroupById(_ id: String) -> Group? {
        return decryptedGroups.first(where: {$0.groupId == id})
    }
    
    func listenForGroupChange() async {
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
    
    func listenForGroupAccept() async {
        await userSocketService.onGroupAccept { response in
            Task {
                try self.security.decryptAdminSymmetryKey(with: response.publicKey, and: response.groupId)
            }
        }
    }
    
    func sendMessage(with groupId: String, isNotification: Bool = false) async {
        if message.isEmpty {
            return
        }
        do {
            let encryptedMsg = try security.encryptMessage(message.trimmingCharacters(in: .whitespacesAndNewlines), for: groupId)
            let msg = OutGoingMessage(message: encryptedMsg, groupId: groupId, isNotification: isNotification)
            try await userSocketService.sendMessage(msg: msg)
            self.message = ""
        } catch {
            print("couldn't encrypt msg for groupId: \(groupId)")
        }
    }
    
    
    func getUserName() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: "username") ?? ""
    }
    
    
    func fetchGroups() async {
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
                    self.setErrorWithMsg(hasError: error != nil)
                    await self.updateUserStatus(isConnected: error == nil)
                }
                if let error = error {
                    print("ping: \(error.localizedDescription)")
                }
            }
        } catch {
            print("fetchGroups error : \(error.localizedDescription)")
            self.setErrorWithMsg(error.localizedDescription)
            onlineStatus = .disconnected
        }
    }
    
    private func setErrorWithMsg(_ msg: String = "", hasError:Bool = true) {
        self.userMessage = msg
        self.hasError = hasError
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
            setErrorWithMsg(hasError: false)
        } catch {
            setErrorWithMsg(error.localizedDescription)
            print("createGroup: \(error.localizedDescription)")
        }
    }
    
    func handleSearchNavigation(groupId: String, foundText: String) {
        if let selectedGroup = getGroupById(groupId) {
            self.selectedGroup = selectedGroup
            self.groupScrollPostion = selectedGroup.messages
                .lastIndex(where: {$0.message
                    .lowercased().contains(foundText)}) ?? 0
            self.useVmScrollPos = true
            self.navigateToCreatedGroup = true
        }
    }
    
    func requestGroupJoin(groupId: String) async {
        do {
            let publicKey = try security.generateUserPukForGroup(with: groupId)
            let request = JoinRequestOutGoing(publicKey: publicKey, groupId: groupId)
            let response = try await userSocketService.joinGroup(with: request)
            print(response)
        } catch {
            setErrorWithMsg(error.localizedDescription)
        }
    }
    
    func fetchUserGroupCreds() async {
        do {
            let response = try await userSocketService.fetchGroupCred()
            //decrypt admin stuff if request was accepted
            for cred in response {
                try security.decryptAdminSymmetryKey(with: cred.publicKey, and: cred.groupId)
            }
            // send back to server to delete cred
            if response.isEmpty { return }
            let delResponse = try await userSocketService.deleteGroupCreds(with: response.map{$0.groupId})
            print("delete res: \(delResponse)")
        } catch {
            print("fetch credentials: \(error.localizedDescription)")
            setErrorWithMsg(error.localizedDescription)
        }
    }
    
    func decryptedGrpMsgs(for group: Group) -> [IncomingMessage] {
        var messages: [IncomingMessage] = []
        do {
            for incoming in group.messages {
                let decipheredMsg = try security.decryptMessage(incoming.message, for: group.groupId)
                messages.append(IncomingMessage(name: incoming.name, message: decipheredMsg, id: incoming.id))
            }
        } catch SecurityException.adminKeyNotFound {
            print("admin key appears to be missing")
        } catch {
            print("couldn't decrypt msg")
        }
        return messages
    }
    
    func decryptAllMsgs() {
        var mGroups = self.groups
        if mGroups.isEmpty {
            self.decryptedGroups = []
            return
        }
        for index in mGroups.indices {
            var group = mGroups[index]
            group.messages = decryptedGrpMsgs(for: group)
            mGroups[index] = group
        }
        self.decryptedGroups = mGroups
    }
}
