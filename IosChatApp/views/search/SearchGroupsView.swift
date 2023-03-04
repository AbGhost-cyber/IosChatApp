//
//  SearchGroupsView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/1.
//

import SwiftUI

struct SearchGroupsView: View {
    @ObservedObject var searchVM: SearchViewModel
    @ObservedObject var userVm: UserSocketViewModel
    @State private var showGroupDetails = false
    @State private var showGroupChat = false
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.dismiss) var dismiss
    
    init(searchVM: SearchViewModel, userVm: UserSocketViewModel) {
        self.searchVM = searchVM
        self.userVm = userVm
        searchVM.setUserGroups(userVm.decryptedGroups)
    }
    
    var body: some View {
        groupListView
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .overlay { groupListSearchOverlay }
            .refreshable {
                await searchVM.searchGroups()
            }
            .sheet(isPresented: $showGroupDetails) {
                SearchDetailView(searchVM: searchVM, onJoinGroup: { groupId in
                    await userVm.requestGroupJoin(groupId: groupId)
                })
                .presentationDetents([.medium])
                .padding(.horizontal)
            }
            .embedZstack()
    }
    func highlightedText(str: String, searched: String) -> Text {
        guard !str.isEmpty && !searched.isEmpty else { return Text(str) }
        var result: Text!
        let parts = str.components(separatedBy: " ")
        for part_index in parts.indices {
            result = (result == nil ? Text("") : result + Text(" "))
            if searched.lowercased().contains(parts[part_index].lowercased().trimmingCharacters(in: .punctuationCharacters)) {
                result = result + Text(parts[part_index])
                    .bold()
                    .foregroundColor(.white)
            }
            else {
                result = result + Text(parts[part_index])
            }
        }
        return result ?? Text(str)
    }
    
    private var groupListView: some View {
        List(searchVM.searchedGroups, id: \.groupId) { group in
            HStack {
                GroupIcon(size: 50, icon: group.groupIcon, font: .groupIconMini2)
                VStack(alignment: .leading, spacing: 5) {
                    Text(group.groupName)
                        .font(.primaryBold)
                        .foregroundColor(searchVM.scope == .group ? .primary : .secondary)
                    if searchVM.scope == .group {
                        Text("\(group.users) members")
                            .font(.secondaryText)
                            .lineLimit(3)
                            .foregroundColor(.secondary)
                    } else {
                        highlightedText(str: group.foundText, searched: group.query.lowercased())
                            .font(.secondaryText)
                            .lineLimit(3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onTapGesture {
                if searchVM.isUserGroup(groupId: group.groupId) {
                    dismissSearch()
                    userVm.handleSearchNavigation(groupId: group.groupId, foundText: group.foundText)
                }
            }
            .listRowBackground(Color.clear)
        }
    }
    
    @ViewBuilder
    private var groupListSearchOverlay: some View {
        switch searchVM.phase {
        case .failure(let error):
            NoItemView(text: error.localizedDescription)
        case .empty:
            NoItemView(text: searchVM.emptyListText)
        case .fetching:
            ProgressView()
                .embedZstack()
        default: EmptyView()
        }
    }
}

struct SearchGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchGroupsView(
            searchVM: SearchViewModel(),
            userVm: UserSocketViewModel()
        )
        .preferredColorScheme(.light)
    }
}

