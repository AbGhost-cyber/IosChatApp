//
//  LoginView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/21.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var pwd = ""
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authVm: AuthViewModel
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    CTextField(value: $username, hint: "Username")
                    
                    SecureField("Password", text: $pwd) {
                        doLogin()
                    }
                    .padding(10)
                    .font(.secondaryMedium)
                    .frame(height: 60)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(10.0)
                    .padding(.top)
                    
                    //MARK: buttons
                    VStack {
                        Button { doLogin() }
                    label: {
                        ButtonLabel(text: "Login", isLoading: authVm.isLoading)
                    }.onChange(of: authVm.didSucceedLogin) { newValue in
                        if newValue {
                            dismiss()
                        }
                    }
                        
                        NavigationLink {
                            SignupView(authVm: authVm)
                                .navigationBarBackButtonHidden()
                        } label: {
                            Text("don't have an account?")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .font(.secondaryText)
                                .frame(height: 60)
                                .foregroundColor(.gray)
                                .cornerRadius(12.0)
                                .padding(.top)
                                .disabled(authVm.isLoading)
                        }
                        
                    }
                    .padding(.top)
                }
                .padding()
                .padding(.horizontal, 5)
                .navigationTitle("Welcome back 👋🏾")
                .toolbar {
                    ToolbarItem {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.primaryBold)
                                .foregroundColor(Color(uiColor: .gray))
                        }
                        
                    }
                }
                .alert("Error", isPresented: $authVm.showUserMessage) {
                    Button(role: .cancel, action: {}) {
                        Text("OK")
                    }
                } message: {
                    Text(authVm.userMessage)
                }
                
            }
        }
    }
    
    private func doLogin() {
        Task {
            try await authVm.login(username: self.username,password: self.pwd)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authVm: AuthViewModel())
    }
}
