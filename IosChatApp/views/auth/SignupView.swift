//
//  SignupView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import SwiftUI

struct SignupProps {
    var username: String = ""
    var pwd: String = ""
    var reEnteredPwd: String = ""
}
struct SignupView: View {
    @State private var props: SignupProps = SignupProps()
    @ObservedObject var authVm: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    CTextField(value: $props.username, hint: "Username")
                    
                    SecureField("Password", text: $props.pwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10.0)
                        .padding(.top)
                    
                    SecureField("Re-Enter Password", text: $props.reEnteredPwd) {
                        doSignUp()
                    }
                    .padding(10)
                    .font(.secondaryMedium)
                    .frame(height: 60)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12.0)
                    .padding(.top)
                    
                    //MARK: buttons
                    VStack {
                        Button { doSignUp() }
                    label: {
                        ButtonLabel(text: "Create an account", isLoading: authVm.isLoading)
                    }.onChange(of: authVm.didSucceedSignup) { newValue in
                        if newValue {
                            dismiss()
                        }
                    }
                        
                        NavigationLink {
                            LoginView(authVm: authVm)
                                .navigationBarBackButtonHidden()
                        } label: {
                            Text("Already have an account?")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .font(.secondaryText)
                                .frame(height: 60)
                                .foregroundColor(.gray)
                                .cornerRadius(12.0)
                                .padding(.top)
                        }
                    }
                    .padding(.top)
                    
                    
                }
                .padding()
                .padding(.horizontal, 5)
                .navigationTitle("Create an account")
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
    
    private func doSignUp() {
        Task {
            try await authVm.signup(
                username: props.username,
                password: props.pwd,
                repeatedPwd: props.reEnteredPwd
            )
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authVm: AuthViewModel())
    }
}
