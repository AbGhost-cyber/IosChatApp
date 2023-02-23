//
//  Extension.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import Foundation
import SwiftUI

extension Font {
    static var welcome: Font {
        boldFont(27)
    }
    
    static var groupIcon: Font {
        boldFont(80)
    }
    static var groupIconMini: Font {
        boldFont(40)
    }
    
    static var signupTitle: Font {
        boldFont(27)
    }
    static var welcomeBtn: Font {
        regularFont(16)
    }
    static var welcomeDesc: Font {
        regularFont(18)
    }
    static var secondaryMedium: Font {
        regularFont(18)
    }
    static var primaryBold: Font {
        boldFont(18)
    }
    static var secondaryText: Font {
        regularFont(16)
    }
    static var secondaryBold: Font {
        boldFont(16)
    }
    
    private static func regularFont(_ size: CGFloat) -> Font {
        return .custom("ProximaNova-Regular", size: size)
    }
    private static func boldFont(_ size: CGFloat) -> Font {
        return .custom("ProximaNova-Bold", size: size)
    }
}

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropFirst())
            }
        }
        return self
    }
}
extension Group {
    static var stub: [Group] {
        [
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "Android Developers",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "124"),
            Group(groupId: "12", groupIcon: "J", groupName: "Jesus my role model",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "123"),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "TRUTH OF THE WORD",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "12"),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "Android Developers",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "12345")
        ]
    }
}

extension URLResponse {
    func validateHTTPResponse() throws -> Int {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw ServiceError.invalidResponseType
        }
        guard 200...299 ~= httpResponse.statusCode ||
                400...499 ~= httpResponse.statusCode else {
            throw ServiceError.httpStatusCodeFailed(statusCode: httpResponse.statusCode, error: nil)
        }
        return httpResponse.statusCode
    }
}
