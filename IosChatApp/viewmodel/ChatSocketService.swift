//
//  ChatService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/12.
//

import Foundation
protocol ChatSocketService {
    func initSession() async throws
    func sendMessage() async throws
    func closeSession() async
    func observeMessages() async throws
}

class EndPoints {
    let url: String
    init(url: String) {
        self.url = url
    }
}
extension EndPoints {
    static let BASE_URL = "ws://localhost:8081"
    static var ChatSocket: EndPoints {
        EndPoints(url: "\(BASE_URL)/chat")
    }
}


