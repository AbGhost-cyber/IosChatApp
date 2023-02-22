//
//  ChatService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation

protocol UserSocketService {
    func connectToServer(token: String, callback: @escaping(Error?)-> Void) async throws
}


class UserSocketImpl: UserSocketService {
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connectToServer(token: String, callback: @escaping(Error?)-> Void ) async throws {
        var request = URLRequest(url: URL(string: EndPoints.InitConnect.url)!)
        let authValue = "Bearer \(token)"
        request.timeoutInterval = 5
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        try await onReceive()
        sendPing { error in
            if error != nil {
                //retry silently
                Task {
                    try await self.connectToServer(token: token, callback: callback)
                }
            }
            callback(error)
        }
    }
    
    func onReceive() async throws {
        let webSocketMessage = try await webSocketTask?.receive()
        if case .string(let data) = webSocketMessage {
            print("data: \(data)")
        }
    }
    
    func sendPing(callback: @escaping(Error?) -> Void) {
        webSocketTask?.sendPing(pongReceiveHandler: callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.sendPing(callback: callback)
        }
    }
}
