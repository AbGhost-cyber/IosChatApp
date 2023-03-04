//
//  SearchDetailView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/4.
//

import SwiftUI

struct SearchDetailView: View {
    @ObservedObject var searchVM: SearchViewModel
    @State private var selectedGroupSearch: SearchData? = nil
    var onJoinGroup: ((String) async -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    init(searchVM: SearchViewModel, onJoinGroup: ((String) async -> Void)? = nil) {
        self.searchVM = searchVM
        self.onJoinGroup = onJoinGroup
    }
    
    var body: some View {
        details
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
        .onAppear {
            selectedGroupSearch = searchVM.selectedSearchData
        }
    }
    
    @ViewBuilder
    private var details: some View {
        if let selectedGroupSearch = Group.stub.first?.toSearchData(query: "A") {
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
                   // await userVm.requestGroupJoin(groupId: selectedGroupSearch.groupId)
                    await onJoinGroup?(selectedGroupSearch.groupId)
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
        }
    }
}

struct SearchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SearchDetailView(searchVM: .init())
    }
}
