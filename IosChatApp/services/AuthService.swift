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
enum ServiceError: Error {
    case invalidURL
    case invalidResponseType
    case httpStatusCodeFailed(statusCode: Int, error: Error?)
    case unknownError
    case tokenNotFound
    case decodingError
    case encodingError
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
            throw ServiceError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(authRequest)
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = try response.validateHTTPResponse()
        if let serverStrResponse = String(data: data, encoding: .utf8) {
            return (serverStrResponse, (200...299).contains(statusCode))
        }
        throw ServiceError.unknownError
    }
}
