//
//  SignupView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import SwiftUI

struct SignupView: View {
    @State private var username = ""
    @State private var pwd = ""
    @State private var reEnteredPwd = ""
    
    @Environment(\.dismiss) var dismiss
    
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
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(10.0)
                    
                    TextField("Password", text: $pwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(.top)
                    
                    TextField("Re-Enter Password", text: $pwd)
                        .padding(10)
                        .font(.secondaryMedium)
                        .frame(height: 60)
                        .background(Color.white)
                        .cornerRadius(12.0)
                        .padding(.top)
                        .foregroundColor(.black)
                    
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
                        
                        Button {
                            
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
                                .foregroundColor(Color(uiColor: .gray))
                        }

                    }
                }
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
