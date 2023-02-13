//
//  ChatViewModel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/12.
//

enum SocketError: Error {
    case invalidURL
}
struct Message: Codable, Hashable {
    let name: String?
    let message: String
    let id: String
}

import Foundation
@MainActor
class ChatViewModel: ObservableObject, ChatSocketService {
    private var webSocketTasK: URLSessionWebSocketTask?
    @Published var currentUserName: String = ""
    @Published var userMessage: String = ""
    @Published var userCount: Int = 0
    @Published var receivedMessages: [Message] = []

    
    func initSession() async throws {
        if(self.currentUserName.isEmpty) { return }
        let session = URLSession.shared
        if let url = URL(string: "\(EndPoints.ChatSocket.url)?username=\(self.currentUserName)") {
            webSocketTasK = session.webSocketTask(with: url)
            webSocketTasK?.resume()
            try await observeMessages()
            return
        }
        throw SocketError.invalidURL
    }
    func sendMessage() async throws {
        guard !self.userMessage.isEmpty, !self.currentUserName.isEmpty else { return }
        let message = Message(name: self.currentUserName, message: self.userMessage, id: UUID().uuidString)
        let data = try JSONEncoder().encode(message)
        try await webSocketTasK?.send(.string(String(data: data, encoding: .utf8)!))
        self.userMessage = ""
    }
    
    func observeMessages() async throws {
        let socketTaskMessage =  try await webSocketTasK?.receive()
        if case .string(let stringResult) = socketTaskMessage {
            if let rawData = stringResult.data(using: .utf8) {
                if let incomingMessage = try? JSONDecoder().decode(Message.self, from: rawData) {
                    self.receivedMessages.append(incomingMessage)
                } else {
                    // it is users count
                    let count = try JSONDecoder().decode(Int.self, from: rawData)
                    self.userCount = count
                }
                //TODO: ability to create groups, ability to add, admin to remove, ability to leave
                try await observeMessages()
            }
        }
    }
    func closeSession() async {
        webSocketTasK?.cancel(with: .normalClosure, reason: nil)
    }
}
