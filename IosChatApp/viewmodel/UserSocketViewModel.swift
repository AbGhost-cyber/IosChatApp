//
//  UserSocketViewModel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation

enum TokenException: Error {
    case notFound
}
enum ConnState {
    case connecting
    case connected
    case disconnected
    
    var text: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .connected:
            return "Chats"
        case .disconnected:
            return "Disconnected"
        }
    }
}

@MainActor
class UserSocketViewModel: ObservableObject {
    
    @Published var onlineStatus: ConnState = .disconnected
    
    private let userSocketService: UserSocketService
    
    init(userSocketService: UserSocketService = UserSocketImpl()) {
        self.userSocketService = userSocketService
    }
    
    private func updateUserStatus(isConnected: Bool) async {
       await MainActor.run {
            self.onlineStatus = isConnected ? .connected : .disconnected
        }
    }
    
    @MainActor func connectToServer() async throws {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: "token") else {
            throw TokenException.notFound
        }
        onlineStatus = .connecting
        do {
            try await userSocketService.connectToServer(token: token, callback: { error in
                Task {
                    await self.updateUserStatus(isConnected: error == nil)
                }
            })
        } catch {
            print("an error occurred: \(error.localizedDescription)")
        }
    }
}
