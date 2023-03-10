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
    static var groupIconMini1: Font {
        boldFont(65)
    }
    static var groupIconMini2: Font {
        boldFont(25)
    }
    static var groupIconMini3: Font {
        boldFont(30)
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
    static var secondaryLarge: Font {
        regularFont(23)
    }
    static var primaryBold: Font {
        boldFont(18)
    }
    static var primaryBold2: Font {
        boldFont(21)
    }
    
    static var secondaryText: Font {
        regularFont(16)
    }
    
    static var secondaryTextMini: Font {
        regularFont(14)
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
                  users: ["Ab", "Ud", "Joseph", "Aloy", "Aloy5", "Aloy2", "Aloy111", "Aloy12", "Aloy1", "Aloy33"], requests: [JoinRequestIncoming(publicKey: [], username: "paul"), JoinRequestIncoming(publicKey: [], username: "felix")], messages: [IncomingMessage(name: "Ab", message: "Hey there", id: "12"), IncomingMessage(name: "Ab", message: "Hey", id: "123"),IncomingMessage(name: "Dremo", message: "Hey there", id: "1234"), IncomingMessage(name: "", message: "Admin added dremo", id: "12")], currentUserIsAdmin: true, id: "124", adminName: "Ab", updatedTime: 12),
            Group(groupId: "12", groupIcon: "J", groupName: "Jesus my role model",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], currentUserIsAdmin: false, id: "123", adminName: "Ab", updatedTime: 12),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "TRUTH OF THE WORD",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], currentUserIsAdmin: false, id: "12", adminName: "Ab", updatedTime: 12),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "Android Developers",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], currentUserIsAdmin: false, id: "12345", adminName: "Ab",updatedTime: 12)
        ]
    }
    
    func toSearchData(query: String) -> SearchData {
        let message = self.messages.last(where: {$0.message.lowercased().contains(query.lowercased())})?.message ?? "message not found"
        let data =  SearchData(
            groupId: self.groupId,
            dateCreated: self.dateCreated,
            groupIcon: self.groupIcon,
            groupName: self.groupName,
            groupUrl: self.groupUrl,
            users: self.users.count,
            query: query,
            foundText: message)
        return data
    }
}



extension SearchGroupResponse {
    static var stubs: [SearchGroupResponse] {
        [
            SearchGroupResponse(groupId: "12", dateCreated: 12, groupIcon: "👧🏾", groupName: "Android Developers",
                                groupUrl: "", users: 10),
            SearchGroupResponse(groupId: "123", dateCreated: 12, groupIcon: "A", groupName: "Joyful Ministries",
                                groupUrl: "", users: 200),
            SearchGroupResponse(groupId: "1231", dateCreated: 12, groupIcon: "👧🏾", groupName: "Swift Developers", groupUrl: "", users: 13)
        ]
    }
    
    func toSearchData() -> SearchData {
        let data =  SearchData(groupId: self.groupId, dateCreated: self.dateCreated, groupIcon: self.groupIcon, groupName: self.groupName, groupUrl: self.groupUrl, users: self.users, query: "", foundText: "")
        return data
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

extension URLRequest {
    static func requestWithToken(url: URL, addAppHeader: Bool = false) throws -> URLRequest {
        var request = URLRequest(url: url)
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: "token") else {
            throw ServiceError.tokenNotFound
        }
        let authValue = "Bearer \(token)"
        request.timeoutInterval = 5
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        if addAppHeader {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

extension URL {
    static func getUrlString(urlString: String) throws -> URL {
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }
        return url
    }
}

//extension Sequence {
//    func concurrentForEach(
//        _ operation: @escaping (Element) async throws -> Void
//    ) async {
//        // A task group automatically waits for all of its
//        // sub-tasks to complete, while also performing those
//        // tasks in parallel:
//        await withTaskGroup(of: Void.self) { group in
//            for element in self {
//                group.addTask {
//                    do {
//                        try await operation(element)
//                    } catch {
//                        print("error performing task: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//}

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    func fromBase64() -> String? {
        if let data  = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension AsyncButton {
    enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }
}

extension WelcomeUserView {
    enum SheetAction: Identifiable {
        case getStarted
        case hasAccount
        
        var id: Int {
            switch self {
            case .getStarted: return 1
            case .hasAccount: return 2
            }
        }
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    var customFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self)
    }
}

extension View {
  
    func hideRowSeperator(with bgColor: Color = .clear) -> some View {
        return self
            .listRowSeparator(.hidden)
            .listRowBackground(bgColor)
    }
    
    func embedZstack() -> some View {
        return ZStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.1))
                .ignoresSafeArea(.all)
            self
        }
    }
}
