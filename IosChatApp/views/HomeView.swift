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
    @State private var searchedText: String = ""
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                List {
                    ForEach(userSocketVm.groups) { group in
                        NavigationLink {
                            Text("Hi")
                        } label: {
                            chatRowView(group: group)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
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
                    if userSocketVm.groups.isEmpty {
                        NoItemView(text: "groups you've joined will appear here!")
                    }
                }
                
                .sheet(isPresented: $showCreateGroupSheet) {
                    CreateGroupView(userVm: userSocketVm)
                }
                .searchable(
                    text: $searchedText,
                   prompt: Text("Search Groups")
                )
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
                if userSocketVm.onlineStatus == .connecting || userSocketVm.onlineStatus == .updating {
                    ProgressView()
                }
                Text(userSocketVm.onlineStatus.text)
                    .font(.primaryBold)
                    .foregroundColor(.primary)
            }
        }
    }
    
    @ViewBuilder
    private func chatRowView(group: Group) -> some View {
        HStack {
            Circle()
                .fill(Color.mint)
                .frame(width: 65, height: 65)
                .overlay {
                    Text(group.groupIcon)
                        .font(.groupIconMini)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(group.groupName)
                    .lineLimit(1)
                    .font(.primaryBold)
                Text("Joe: Thanks my bro")
                    .font(.secondaryMedium)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userSocketVm: UserSocketViewModel())
            .preferredColorScheme(.light)
    }
}
