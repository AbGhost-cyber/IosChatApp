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
    static let SOCKET_URL = "ws://localhost:8081"
    static let HTTP_URL = "http://localhost:8081"
    static var ChatSocket: EndPoints {
        EndPoints(url: "\(SOCKET_URL)/chat")
    }
    static var InitConnect: EndPoints {
        EndPoints(url: "\(SOCKET_URL)/connect")
    }
    static var UserGroups: EndPoints {
        EndPoints(url: "\(HTTP_URL)/group")
    }
    static func groupChat(id: String) -> EndPoints {
        return EndPoints(url: "\(SOCKET_URL)/group/\(id)/chat")
    }
}


