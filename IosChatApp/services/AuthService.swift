//
//  AuthService.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import Foundation

struct AuthRequest: Codable {
    let username: String
    let password: String
}
enum AuthError: Error {
    case invalidURL
    case invalidResponseType
    case httpStatusCodeFailed(statusCode: Int, error: Error?)
    case unknownError
}

protocol AuthService {
    func signup(with request: AuthRequest) async throws -> (String, Bool)
    func login(with request: AuthRequest) async throws -> (String, Bool)
}

class AuthServiceImpl: AuthService {
    let baseUrl: URL
    
    init(baseURL: URL) {
        self.baseUrl = baseURL
    }
    
    func signup(with request: AuthRequest) async throws -> (String, Bool) {
         try await handleAuth(path: "signup", authRequest: request)
    }
    func login(with request: AuthRequest) async throws -> (String, Bool) {
        try await handleAuth(path: "login", authRequest: request)
    }
    
    private func handleAuth(path: String, authRequest: AuthRequest) async throws -> (String, Bool) {
        guard let url = URL(string: path, relativeTo: baseUrl) else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(authRequest)
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = try validateHTTPResponse(of: response)
        if let serverStrResponse = String(data: data, encoding: .utf8) {
            //TODO: persist token if path is login
            return (serverStrResponse, (200...299).contains(statusCode))
        }
        throw AuthError.unknownError
    }
    
    
    private func validateHTTPResponse(of response: URLResponse) throws -> Int {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponseType
        }
        guard 200...299 ~= httpResponse.statusCode ||
                400...499 ~= httpResponse.statusCode else {
            throw AuthError.httpStatusCodeFailed(statusCode: httpResponse.statusCode, error: nil)
        }
        return httpResponse.statusCode
    }
}
