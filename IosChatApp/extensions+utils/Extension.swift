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
    static var groupIconMini2: Font {
        boldFont(25)
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
                  users: [], requests: [], messages: [], id: "124", updatedTime: 12),
            Group(groupId: "12", groupIcon: "J", groupName: "Jesus my role model",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "123", updatedTime: 12),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "TRUTH OF THE WORD",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "12", updatedTime: 12),
            Group(groupId: "12", groupIcon: "👧🏾", groupName: "Android Developers",
                  groupDesc: "Android things", groupUrl: "", dateCreated: 12,
                  users: [], requests: [], messages: [], id: "12345", updatedTime: 12)
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

extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async throws -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    do {
                        try await operation(element)
                    } catch {
                        print("error performing task: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

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
