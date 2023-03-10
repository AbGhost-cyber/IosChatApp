//
//  Models.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/23.
//

import Foundation

// to create group
struct Group: Codable, Identifiable, Hashable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.groupId == rhs.groupId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(groupId)
    }
    
    let groupId: String
    let groupIcon: String
    let groupName: String
    let groupDesc: String
    let groupUrl: String
    let dateCreated: Int64
    let users: [String]
    let requests: [JoinRequestIncoming]
    var messages: [IncomingMessage]
    let currentUserIsAdmin: Bool
    let id: String
    let adminName: String
    let updatedTime: Int
}


struct SearchGroupResponse: Decodable {
    let groupId: String
    let dateCreated: Int64
    let groupIcon: String
    let groupName: String
    let groupUrl: String
    let users: Int
}

struct SearchData {
    let groupId: String
    let dateCreated: Int64
    let groupIcon: String
    let groupName: String
    let groupUrl: String
    let users: Int
    let query: String
    let foundText: String
}

struct JoinRequestOutGoing: Codable {
    let publicKey: [UInt8]
    let groupId: String
}
struct JoinRequestIncoming: Codable, Hashable {
    let publicKey: [UInt8]
    let username: String
}
//this would change in the future, we will have two different, one for incoming and other for outgoing
struct IncomingMessage: Codable, Identifiable, Hashable {
    let name: String
    let message: String
    let id: String
}

struct OutGoingMessage: Codable {
    let message: String
    let groupId: String
    let isNotification: Bool
}

struct CreateGroupRequest: Codable {
    let groupName: String
    let groupDesc: String
    let groupIcon: String
}

struct GroupAcceptResponse: Codable {
    let username: String
    let groupId: String
    let publicKey: [UInt8]
    
}

enum WebResponse {
    case groupResponse(Group)
    case notification(String)
    case simpleResponse(String)
    case groupAcceptResponse(GroupAcceptResponse)
    case none
}

enum RequestAction: String {
    case accept
    case reject
}

extension WebResponse: Decodable {
    enum CodingKeys: CodingKey {
        case type
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Int.self, forKey: .type)
        
        switch type {
        case 0:
            let data = try container.decode(String.self, forKey: .data)
            self = .notification(data)
        case 1:
            let data = try container.decode(Group.self, forKey: .data)
            self = .groupResponse(data)
        case 2:
            let data = try container.decode(String.self, forKey: .data)
            self = .simpleResponse(data)
        case 3:
            let data = try container.decode(GroupAcceptResponse.self, forKey: .data)
            self = .groupAcceptResponse(data)
        default:
            self = .none
        }
    }
}

enum FetchPhase<V> {
    
    case initial
    case fetching
    case success(V)
    case failure(Error)
    case empty
    
    var value: V? {
        if case .success(let v) = self {
            return v
        }
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
    
}
