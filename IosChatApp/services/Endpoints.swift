//
//  Endpoints.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/1.
//

import Foundation

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
    static var GroupChat: EndPoints {
        return EndPoints(url: "\(SOCKET_URL)/group/chat")
    }
    static var SearchGroup: EndPoints {
        return EndPoints(url: "\(HTTP_URL)/groups/search")
    }
    static var JoinGroup: EndPoints {
        EndPoints(url: "\(HTTP_URL)/join/group")
    }
    
    static var Groupcred: EndPoints {
        EndPoints(url: "\(HTTP_URL)/fetchGroupCred")
    }
    
    static var DeleteCred: EndPoints {
        EndPoints(url: "\(HTTP_URL)/deleteGroupCred")
    }
    
    static func AdminGroupRequest(groupId: String, for username: String) -> EndPoints {
        EndPoints(url: "\(HTTP_URL)/group/\(groupId)/\(username)/request")
    }
}
