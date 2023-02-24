//
//  ChatService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/23.
//

import Foundation

protocol ChatService {
    func openGroupSocket(with id: String) async throws
}
class ChatServiceImpl : ChatService {
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession = .shared
    
    func openGroupSocket(with id: String) async throws {
        let url = try URL.getUrlString(urlString: EndPoints.groupChat(id: id).url)
        let urlRequest = try URLRequest.requestWithToken(url: url)
        webSocket = session.webSocketTask(with: urlRequest)
        webSocket?.resume()
        try await onReceiveData()
    }
    
    func onReceiveData() async throws {
        // if socket is closed then we stop recursive listening
//        var isActive = true
//        while isActive && webSocket?.closeCode == .invalid {
//            do {
//                let webSocketMessage = try await webSocket?.receive()
//                if case .string(let data) = webSocketMessage {
//                    print("data: \(data)")
//                }
//            } catch {
//                print("receive web socket response error: \(error.localizedDescription)")
//                isActive = false
//            }
//        }
        let webSocketMessage = try await webSocket?.receive()
        if case .string(let data) = webSocketMessage {
            print("data: \(data)")
        }
        else if case .data(let data) = webSocketMessage {
            print(String(data: data, encoding: .utf8))
        }
        try await onReceiveData()
        
    }
}
