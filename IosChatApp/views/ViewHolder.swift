//
//  ViewHolder.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/21.
//

import SwiftUI

struct ViewHolder: View {
    @State private var isloggedIn = false
    @StateObject var authVm: AuthViewModel = .init()
    @StateObject var userSocketVm: UserSocketViewModel = .init()
    
    var body: some View {
        ZStack {
            if authVm.didSucceedLogin {
                HomeView(userSocketVm: userSocketVm)
            }else {
                WelcomeUserView(authVm: authVm)
            }
        }.onAppear {
            print(authVm.didSucceedLogin)
        }.sheet(isPresented: $authVm.didSucceedSignup) {
            //redirect to login if did succeed signup
            LoginView(authVm: authVm)
        }
    }
}

struct ViewHolder_Previews: PreviewProvider {
    static var previews: some View {
        ViewHolder()
    }
}
