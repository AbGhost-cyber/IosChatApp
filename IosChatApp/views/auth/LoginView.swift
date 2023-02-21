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
                Rectangle().fill(Color.gray.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    TextField("Username", text: $username)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10.0)
                    
                    TextField("Password", text: $pwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10.0)
                        .padding(.top)
                    
                    //MARK: buttons
                    VStack {
                        Button {
                            Task {
                                do {
                                    try await authVm.login(
                                        username: self.username,
                                        password: self.pwd
                                    )
                                    print("message: \(authVm.userMessage)")
                                } catch {
                                    //TODO: catch error of authError
                                    authVm.userMessage = error.localizedDescription
                                }
                            }
                        } label: { loginButton }
                        
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
    
    private var loginButton: some View {
        VStack {
            Text("Login")
                .font(.secondaryMedium)
                .fontWeight(.black)
                .opacity(authVm.isLoading ? 0 : 1)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(Color.yellow.opacity(0.6))
        .foregroundColor(.black)
        .cornerRadius(12.0)
        .padding(.top)
        .disabled(authVm.isLoading)
        .overlay {
            if authVm.isLoading {
                ProgressView()
                    .padding(.top, 10)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authVm: AuthViewModel())
    }
}
