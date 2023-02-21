//
//  IosChatAppApp.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/12.
//

import SwiftUI

@main
struct IosChatAppApp: App {
    @StateObject private var authVm: AuthViewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            ViewHolder()
                .environmentObject(authVm)
        }
    }
}
