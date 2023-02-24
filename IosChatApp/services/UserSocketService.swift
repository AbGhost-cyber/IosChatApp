//
//  ChatService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation

protocol UserSocketService {
    func connectToServer(callback: @escaping(Error?)-> Void) async throws
    //fetch groups, fetch group messages, decrypt
    func fetchGroups() async throws -> [Group]
    func createGroup(with request: CreateGroupRequest) async throws
    func connectToGroupChat(with id: String) async throws
}


class UserSocketImpl: UserSocketService {
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession = .shared
    
    func connectToServer(callback: @escaping(Error?)-> Void ) async throws {
        let url = try URL.getUrlString(urlString: EndPoints.InitConnect.url)
        let request = try URLRequest.requestWithToken(url: url)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        try await onReceive()
        sendPing { error in
            if error != nil {
                //retry silently
                Task {
                    try await self.connectToServer(callback: callback)
                }
            }
            callback(error)
        }
    }
    
    
    func fetchGroups() async throws -> [Group] {
        let url = try URL.getUrlString(urlString: EndPoints.UserGroups.url)
        let request = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        let (data, _) = try await session.data(for: request)
        if let groups = try? JSONDecoder().decode([Group].self, from: data) {
            return groups
        }
        throw ServiceError.unknownError
    }
    
    func createGroup(with request: CreateGroupRequest) async throws {
        let url = try URL.getUrlString(urlString: EndPoints.UserGroups.url)
        var urlRequest = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await session.data(for: urlRequest)
        print("create group: \(String(data: data, encoding: .utf8))")
    }
    
    func connectToGroupChat(with id: String) async throws {
        let url = try URL.getUrlString(urlString: EndPoints.groupChat(id: id).url)
        let urlRequest = try URLRequest.requestWithToken(url: url)
        webSocketTask = session.webSocketTask(with: urlRequest)
        webSocketTask?.resume()
        try await onReceive()
    }
    
    func onReceive() async throws {
        let webSocketMessage = try await webSocketTask?.receive()
        if case .string(let data) = webSocketMessage {
            print("data: \(data)")
        }
    }
    
    func sendPing(callback: @escaping(Error?) -> Void) {
        webSocketTask?.sendPing(pongReceiveHandler: callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            print("sent")
            self.sendPing(callback: callback)
        }
    }
}
