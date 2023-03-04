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
        ZStack {
            groupListView
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .overlay { groupListSearchOverlay }
            .refreshable {
                await searchVM.searchGroups()
            }
            .sheet(isPresented: $showGroupDetails) {
                groupDetailView
                    .padding()
                    .presentationDetents([.medium])
            }
        }
    }
    
    @ViewBuilder
    private var groupDetailView: some View {
        if let selectedGroupSearch = searchVM.selectedSearchData {
            VStack(spacing: 10) {
                GroupIcon(size: 120, icon: selectedGroupSearch.groupIcon, font: .groupIconMini1)
                Text(selectedGroupSearch.groupName)
                    .foregroundColor(.primary)
                    .font(.welcome)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Text("Created on \(Date(milliseconds: selectedGroupSearch.dateCreated).customFormat)")
                    .font(.secondaryLarge)
                    .foregroundColor(.secondary)
                    .padding(.top)
                Text("\(selectedGroupSearch.users) member(s)")
                    .font(.secondaryLarge)
                    .foregroundColor(.accentColor)
                AsyncButton {
                    await userVm.requestGroupJoin(groupId: selectedGroupSearch.groupId)
                } label: {
                    VStack {
                        Text("Join Group")
                            .foregroundColor(.white)
                            .font(.primaryBold2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(.primary.opacity(0.7))
                    .cornerRadius(12.0)
                    .padding(.top)
                }

            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .foregroundColor(.secondary)
                    .bold()
                    .padding(10)
                    .overlay {
                        Circle().fill(Color.primary.opacity(0.15))
                    }
                    .offset(y: -40)
                    .onTapGesture { dismiss() }
                    
            }
        } else {
            Text("didn't fetch")
        }
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
                print("tapped group")
                showGroupDetails = !searchVM.userIsGroupMember(groupdId: group.groupId)
                if showGroupDetails {
                    searchVM.selectedSearchData = group
                    return
                }
                if let selectedGroup = userVm.getGroupById(group.groupId) {
                    userVm.selectedGroup = selectedGroup
                    userVm.groupScrollPostion = selectedGroup.messages.lastIndex(where: {$0.message.contains(group.foundText)}) ?? 0
                    userVm.useVmScrollPos = true
                    dismissSearch()
                    userVm.navigateToCreatedGroup = true
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
                .overlayWithBg()
        case .empty:
            NoItemView(text: searchVM.emptyListText)
                .overlayWithBg()
        case .fetching:
            ProgressView()
                .overlayWithBg()
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
        .preferredColorScheme(.dark)
    }
}

