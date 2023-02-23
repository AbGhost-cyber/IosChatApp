//
//  Models.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/23.
//

import Foundation

struct Group: Codable, Identifiable {
    let groupId: String
    let groupIcon: String
    let groupName: String
    let groupDesc: String
    let groupUrl: String
    let dateCreated: Int64
    let users: [String]
    let requests: [JoinRequest]
    let messages: [IncomingMessage]
    let id: String
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
