//
//  Models.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/23.
//

import Foundation

// to create group
struct Group: Codable, Identifiable {
    let groupId: String
    let groupIcon: String
    let groupName: String
    let groupDesc: String
    let groupUrl: String
    let dateCreated: UInt64
    let users: [String]
    let requests: [JoinRequest]
    let messages: [IncomingMessage]
    let id: String
    let updatedTime: Int
}

struct JoinRequest: Codable {
    let publicKey: [UInt8]
}

//this would change in the future, we will have two different, one for incoming and other for outgoing
struct IncomingMessage: Codable, Identifiable {
    let name: String
    let message: String
    let id: String
}
struct CreateGroupRequest: Codable {
    let groupName: String
    let groupDesc: String
    let groupIcon: String
}

enum WebResponse {
    case groupResponse(Group)
    case notification(String)
    case simpleResponse(String)
    case none
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
        default:
            self = .none
        }
    }
}
