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
    @Published var alertTitle: String = ""
    @Published var alertMsg: String = "" {
        didSet {
            showUserMessage = !alertMsg.isEmpty
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
            self.alertTitle = "Missing Fields ❌"
            self.alertMsg = "required fields cannot be empty"
            return
        }
        let authRequest = AuthRequest(username: username, password: password)
        do {
            let (response, didSucceed) = try await authService.login(with: authRequest)
            self.alertTitle = didSucceed ? "Success" : "Error"
            setLoadingAndMessage(isLoading: false, userMessage: didSucceed ? "" : response)
            defaults.set(didSucceed, forKey: "isLoggedIn")
            //save user token local
            if didSucceed {
                defaults.set(response, forKey: "token")
                defaults.set(username, forKey: "username")
            }
            self.didSucceedLogin = didSucceed
        } catch {
            //TODO: catch error of authError
            self.alertTitle = "Error"
            setLoadingAndMessage(isLoading: false, userMessage: error.localizedDescription)
        }
    }
    
    private func setLoadingAndMessage(isLoading: Bool, userMessage: String) {
        self.isLoading = isLoading
        self.alertMsg = userMessage
    }
    
    func signup(username: String, password: String, repeatedPwd: String) async throws {
        if password != repeatedPwd {
            self.alertTitle = "Error"
            self.alertMsg = "password doesn't match"
            return
        }
        let isValid = !password.isEmpty && !username.isEmpty && !repeatedPwd.isEmpty
        if !isValid {
            self.alertTitle = "Missing Fields ❌"
            self.alertMsg = "required fields cannot be empty"
            return
        }
        self.isLoading = true
        let authRequest = AuthRequest(username: username, password: password)
        do {
            let (response, didSucceed) = try await authService.signup(with: authRequest)
            self.alertTitle = didSucceed ? "Success" : "Error"
            setLoadingAndMessage(isLoading: false, userMessage: response)
            self.didSucceedSignup = didSucceed
        } catch {
            //TODO: catch error of authError
            self.alertTitle = "Error"
            setLoadingAndMessage(isLoading: false, userMessage: error.localizedDescription)
        }
    }
}
