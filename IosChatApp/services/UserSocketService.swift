//
//  ChatService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation

protocol UserSocketService {
    func fetchGroups() async throws -> [Group]
    func openGroupSocket(callback: @escaping(Error?)-> Void) async throws
    func createGroup(with request: CreateGroupRequest) async throws -> Group
    func onGroupChange(callback: @escaping(Group) -> Void) async
    func sendMessage(text: String, groupId: String) async throws
    func searchGroups(with keyword: String) async throws -> [SearchGroupResponse]
    func joinGroup(with request: JoinRequestOutGoing) async throws -> String
    func fetchGroupCred() async throws -> [GroupAcceptResponse]
}

class UserSocketImpl: UserSocketService {
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession = .shared
    private var groupCallback: ((Group) -> Void)?
    private var sockets: Dictionary<String, URLSessionWebSocketTask> = [:]
    
    func openGroupSocket(callback: @escaping(Error?)-> Void) async throws {
        let url = try URL.getUrlString(urlString: EndPoints.GroupChat.url)
        let urlRequest = try URLRequest.requestWithToken(url: url)
        webSocketTask = session.webSocketTask(with: urlRequest)
        webSocketTask?.resume()
        sendPing { error in
            callback(error)
        }
        try await onReceiveData()
    }

    
    func onGroupChange(callback: @escaping(Group) -> Void) async {
        groupCallback = callback
    }
    
    func fetchGroups() async throws -> [Group] {
        let url = try URL.getUrlString(urlString: EndPoints.UserGroups.url)
        let request = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        let (data, _) = try await session.data(for: request)
        if let groups = try? JSONDecoder().decode([Group].self, from: data) {
            return groups
        }
        throw ServiceError.decodingError
    }
    
    func createGroup(with request: CreateGroupRequest) async throws -> Group {
        let url = try URL.getUrlString(urlString: EndPoints.UserGroups.url)
        var urlRequest = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await session.data(for: urlRequest)
        if let group = try? JSONDecoder().decode(Group.self, from: data) {
            return group
        }
        throw ServiceError.decodingError
    }
    
    func sendMessage(text: String, groupId: String) async throws {
        let msg = OutGoingMessage(message: text, groupId: groupId)
        let data = try JSONEncoder().encode(msg)
        if let dataStr = String(data: data, encoding: .utf8) {
            try await webSocketTask?.send(.string(dataStr))
        }
    }
    
    
   private func onReceiveData() async throws {
       var isActive = true
       while isActive && webSocketTask?.closeCode == .invalid {
           do {
               let webSocketMessage = try await webSocketTask?.receive()
               if case .string(let dataJson) = webSocketMessage {
                   guard let data  = dataJson.data(using: .utf8) else { return }
                   
                   if let result = try? JSONDecoder().decode(WebResponse.self, from: data) {
                       if case .groupResponse(let group) = result {
                           guard let groupCallback = groupCallback else { return }
                           groupCallback(group)
                       }
                       if case .simpleResponse(let response) = result {
                           print("simple response: \(response)")
                       }
                   }else {
                       print("couldnt decode")
                   }
               }
           } catch {
               print("on receive failed: \(error.localizedDescription)")
               isActive = false
           }
       }
    }
    
    func sendPing(callback: @escaping(Error?) -> Void) {
        webSocketTask?.sendPing(pongReceiveHandler: callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.sendPing(callback: callback)
        }
    }
    
    func searchGroups(with keyword: String) async throws -> [SearchGroupResponse] {
        var url = try URL.getUrlString(urlString: EndPoints.SearchGroup.url)
        url.append(queryItems: [.init(name: "keyword", value: keyword)])
        let request = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        let (data, _) = try await session.data(for: request)
        if let groups = try? JSONDecoder().decode([SearchGroupResponse].self, from: data) {
            return groups
        }
       throw ServiceError.decodingError
    }
    
   
    
    func joinGroup(with request: JoinRequestOutGoing) async throws -> String {
        let url = try URL.getUrlString(urlString: EndPoints.JoinGroup.url)
        var urlRequest = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await session.data(for: urlRequest)
        if let response = String(data: data, encoding: .utf8) {
            return response
        }
        throw ServiceError.decodingError
    }
    
    func fetchGroupCred() async throws -> [GroupAcceptResponse] {
        let url = try URL.getUrlString(urlString: EndPoints.Groupcred.url)
        let request = try URLRequest.requestWithToken(url: url, addAppHeader: true)
        let (data, _) = try await session.data(for: request)
        if let credentials = try? JSONDecoder().decode([GroupAcceptResponse].self, from: data) {
            return credentials
        }
        throw ServiceError.decodingError
    }
}
