//
//  AuthViewModel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/21.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var loginSucceed: Bool = false
    @Published var showUserMessage: Bool = false
    @Published var userMessage: String = "" {
        didSet {
            showUserMessage = !userMessage.isEmpty
        }
    }
    @Published var isLoading = false
    @Published var didSucceedLogin = false
    @Published var didSucceedSignup = false
    
    private let authService: AuthService
    private let defaults = UserDefaults.standard
    
    init(authService: AuthService = AuthServiceImpl(baseURL: URL(string: "http://localhost:8081/")!)) {
        self.authService = authService
        self.didSucceedLogin = defaults.bool(forKey: "isLoggedIn")
    }
    
    func login(username: String, password: String) async throws {
        self.isLoading = true
        let isValid = !password.isEmpty && !username.isEmpty
        if !isValid {
            self.userMessage = "required fields cannot be empty"
            return
        }
        let authRequest = AuthRequest(username: username, password: password)
        let (response, didSucceed) = try await authService.login(with: authRequest)
        self.isLoading = false
        self.userMessage = didSucceed ? "" : response
        self.didSucceedLogin = didSucceed
        defaults.set(didSucceed, forKey: "isLoggedIn")
        //save user token local
        if didSucceed {
            defaults.set(response, forKey: "token")
        }
    }
    
    func signup(username: String, password: String, repeatedPwd: String) async throws {
        if password != repeatedPwd {
            self.userMessage = "password doesn't match"
            return
        }
        let isValid = !password.isEmpty && !username.isEmpty && !repeatedPwd.isEmpty
        if !isValid {
            self.userMessage = "required fields cannot be empty"
            return
        }
        self.isLoading = true
        let authRequest = AuthRequest(username: username, password: password)
        let (response, didSucceed) = try await authService.signup(with: authRequest)
        self.isLoading = false
        self.userMessage = response
        self.didSucceedSignup = didSucceed
    }
}