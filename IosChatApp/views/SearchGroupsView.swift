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
    
    var body: some View {
        ZStack {
            groupListView
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .overlay { groupListSearchOverlay }
            .refreshable {
                // await searchVM.searchGroups()
            }
        }
    }
    
    private var groupListView: some View {
        List(searchVM.searchedGroups, id: \.groupId) { group in
            HStack {
                GroupIcon(size: 50, icon: group.groupIcon, font: .groupIconMini2)
                VStack(alignment: .leading, spacing: 5) {
                    Text(group.groupName)
                        .font(.primaryBold)
                        .foregroundColor(.primary)
                    Text("\(group.users) members")
                        .font(.secondaryText)
                        .foregroundColor(.secondary)
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

extension View {
    func overlayWithBg() -> some View {
        return self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.1))
    }
}
