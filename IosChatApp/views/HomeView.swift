//
//  HomeView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import SwiftUI

struct HomeView: View {
    @State private var showCreateGroupSheet = false
    @ObservedObject var userSocketVm: UserSocketViewModel
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    
                }
//                .navigationTitle("Chats")
//                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    createGroupIcon
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(.primary)
                            .font(.primaryBold)
                    }
                    onlineStatus
                }
                .overlay {
                    NoItemView(text: "groups you've joined will appear here!")
                }
                
                .sheet(isPresented: $showCreateGroupSheet) {
                    CreateGroupView()
                }
                .onAppear {
                    Task {
                        try await userSocketVm.connectToServer()
                    }
                }
            }
        }
    }
    
    private var createGroupIcon: some ToolbarContent {
        ToolbarItem {
            Button {
                self.showCreateGroupSheet = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .renderingMode(.template)
                    .foregroundColor(Color.primary)
                    .font(.primaryBold)
            }
        }
    }
    
    
    private var onlineStatus: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 10) {
                if userSocketVm.onlineStatus == .connecting {
                    ProgressView()
                }
                Text(userSocketVm.onlineStatus.text)
                    .font(.primaryBold)
                    .foregroundColor(.primary)
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userSocketVm: UserSocketViewModel())
            .preferredColorScheme(.light)
    }
}
