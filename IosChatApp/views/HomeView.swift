//
//  HomeView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import SwiftUI

struct HomeView: View {
    @State private var showCreateGroupSheet = false
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    
                }
                .navigationTitle("Chats")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    createGroupIcon
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(Color.primary)
                    }
                }
                .overlay {
                    NoItemView(text: "groups you've joined will appear here!")
                }
                
                .sheet(isPresented: $showCreateGroupSheet) {
                    CreateGroupView()
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
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.light)
    }
}
