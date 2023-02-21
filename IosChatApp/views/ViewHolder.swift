//
//  ViewHolder.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/21.
//

import SwiftUI

struct ViewHolder: View {
    @State private var isloggedIn = false
    @EnvironmentObject var authVm: AuthViewModel
    var body: some View {
        ZStack {
            if authVm.didSucceedLogin {
                ContentView()
            }else {
                WelcomeUserView(authVm: authVm)
            }
        }.onAppear {
            print(authVm.didSucceedLogin)
        }
    }
}

struct ViewHolder_Previews: PreviewProvider {
    static var previews: some View {
        ViewHolder()
            .environmentObject(AuthViewModel())
    }
}