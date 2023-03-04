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
    @StateObject var searchVm: SearchViewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                groupListView
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .navigationDestination(isPresented: $userSocketVm.navigateToCreatedGroup) {
                        if userSocketVm.selectedGroup != nil {
                            GroupChatView(userVm: userSocketVm)
                        }
                    }
                    .toolbar {
                        createGroupIcon
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                                .foregroundColor(.primary)
                                .font(.primaryBold)
                        }
                        onlineStatus
                    }
                    .overlay { overlayView }
                    .sheet(isPresented: $showCreateGroupSheet) {
                        CreateGroupView(userVm: userSocketVm)
                    }
                    .searchable(text: $searchVm.keyword, prompt: "Search Groups")
                    .searchScopes($searchVm.scope) {
                        Text("group").tag(SearchScope.group)
                        Text("chat").tag(SearchScope.chat)
                    }
                    .task { doOnStart() }
                    .refreshable { doOnStart() }
                       
            }
        }
    }
    
    private func doOnStart() {
        Task {
            await userSocketVm.fetchGroups()
        }
        
        Task {
            await userSocketVm.fetchUserGroupCreds()
        }
        
        Task {
            await userSocketVm.listenForMessages()
        }
    }
    
    private var groupListView: some View {
        List {
            let sortedGroups = userSocketVm.decryptedGroups
                .sorted(by: {$0.updatedTime > $1.updatedTime})
            ForEach(sortedGroups) { group in
                NavigationLink {
                    GroupChatView(userVm: userSocketVm)
                        .onAppear {
                            userSocketVm.selectedGroup = group
                        }
                } label: {
                    chatRowView(group: group)
                }
            }
            .listRowBackground(Color.clear)
        }
        .opacity(searchVm.isSearching ? 0 : 1)
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
    
    @ViewBuilder
    private var overlayView: some View {
        if userSocketVm.decryptedGroups.isEmpty && !searchVm.isSearching {
            NoItemView(text: "groups you've joined will appear here!")
        }
        if searchVm.isSearching {
            SearchGroupsView(searchVM: searchVm, userVm: userSocketVm)
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
    
    func getMessageToDisplay(for group: Group) -> String {
        var messageToDisplay = ""
        if let lastMessage = group.messages.last {
            messageToDisplay = "\(lastMessage.name): \(lastMessage.message)"
        }
        if messageToDisplay.isEmpty {
            return "no messages yet"
        }
        return messageToDisplay
    }
    
    @ViewBuilder
    private func chatRowView(group: Group) -> some View {
        HStack {
            GroupIcon(
                size: 65,
                icon: group.groupIcon,
                font: .groupIconMini
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(group.groupName)
                    .lineLimit(1)
                    .font(.primaryBold)
                Text(getMessageToDisplay(for: group))
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
