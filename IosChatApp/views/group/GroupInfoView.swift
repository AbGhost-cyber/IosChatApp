//
//  GroupInfoView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/28.
//

import SwiftUI

struct GroupInfoView: View {
    @ObservedObject var userVm: UserSocketViewModel
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.primary.opacity(0.1))
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .center) {
                    if let group = userVm.selectedGroup {
                        
                        GroupIcon(size: 150, icon: group.groupIcon, font: .groupIcon)
                            .padding(.top)
                        
                        Text(group.groupName)
                            .font(.groupIconMini)
                            .foregroundColor(.primary)
                        Text("Group")
                            .font(.secondaryLarge)
                            .foregroundColor(.secondary)
                        HStack {
                            iconText("call", icon: "phone.fill.badge.plus")
                            iconText("search", icon: "magnifyingglass")
                        }
                        .padding()
                        
                        //MARK: group description
                        ExpandableText(group.groupDesc, lineLimit: 3)
                            .font(.secondaryMedium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 50)
                            .padding()
                            .background(Color.primary.opacity(0.1))
                            .cornerRadius(12.0)
                            .padding()
                        
                        //More soon

                    }
                }
                
            }
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Text("Group info")
                    .font(.secondaryMedium)
                    .foregroundColor(.primary)
            }
            if let group = userVm.selectedGroup {
                if group.currentUserIsAdmin {
                    ToolbarItem {
                        Button {
                            
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
    
    private func iconText(_ text: String, icon: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .imageScale(.large)
                .bold()
            Text(text)
                .font(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(12.0)
        .foregroundColor(.accentColor)
    }
}

struct GroupInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GroupInfoView(userVm: UserSocketViewModel())
        }
    }
}
