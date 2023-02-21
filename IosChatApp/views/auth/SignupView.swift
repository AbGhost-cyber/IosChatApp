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
                Rectangle().fill(Color.gray.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    TextField("Username", text: $props.username)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10.0)
                    
                    SecureField("Password", text: $props.pwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10.0)
                        .padding(.top)
                    
                    SecureField("Re-Enter Password", text: $props.reEnteredPwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(12.0)
                        .padding(.top)
                    
                    //MARK: buttons
                    VStack {
                        Button {
                            
                        } label: {
                            Text("Create an account")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .font(.secondaryMedium)
                                .fontWeight(.black)
                                .frame(height: 60)
                                .background(Color.yellow.opacity(0.6))
                                .foregroundColor(.black)
                                .cornerRadius(12.0)
                                .padding(.top)
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
                .onAppear {
                    print("called from sign up")
                }
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authVm: AuthViewModel())
    }
}
