//
//  GroupInfoView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/28.
//

import SwiftUI

struct GroupInfoView: View {
    @ObservedObject var userVm: UserSocketViewModel
    //TODO: make it possible to scan qr code and generate group qr code
    @State private var group: Group = Group.stub[0]
    @State private var showGroupRequestSheet = false
    
    var body: some View {
        List {
            groupProfileView
            
            Section {
                HStack {
                    iconText("audio", icon: "phone.fill")
                    iconText("video", icon: "video.fill")
                    iconText("search", icon: "magnifyingglass")
                }
            }.hideRowSeperator(with: .secondary.opacity(0.1))
            
            Section {
                ExpandableText(group.groupDesc, lineLimit: 3)
                    .font(.secondaryMedium)
                    .padding(10.0)
            }.hideRowSeperator(with: .secondary.opacity(0.1))
            
            if group.currentUserIsAdmin {
                Section {
                    formLabel("Group Requests", icon: "bell.fill", color: .mint, badge: String(group.requests.count))
                } footer: {
                    Text("check here often to view those who are interested in joining your group:)")
                    
                }.hideRowSeperator(with: .secondary.opacity(0.1))
                    .onTapGesture {
                        showGroupRequestSheet = true
                    }
            }
            
            Section {
                formLabel("Starred Messages", icon: "star.fill", badge: "12")
            }.hideRowSeperator(with: .secondary.opacity(0.1))
            
            Section {
                formLabel("Mute", icon: "speaker.slash", color: .accentColor)
                formLabel("Wallpaper & Sound", icon: "text.below.photo.fill", color: .pink)
            }.listRowBackground(Color.secondary.opacity(0.1))
            
            Section {
                formLabel("Encryption", icon: "lock.fill", color: .accentColor, isEnc: true)
            }.listRowBackground(Color.secondary.opacity(0.1))
            
            groupCountAndSearchView
            
            groupUsersProfileList
            
            dangerousZone
            
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Group info")
                    .font(.primaryBold)
                    .foregroundColor(.primary)
            }
            if let isAdmin = userVm.selectedGroup?.currentUserIsAdmin {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear {
            if let selectedGroup = userVm.selectedGroup {
                self.group = selectedGroup
                //
            }
        }
        .sheet(isPresented: $showGroupRequestSheet) {
            GroupRequestView(userVm: userVm)
        }
        .embedZstack()
        
    }
    
    private var groupUsersProfileList: some View {
        Section {
            ForEach(group.users.prefix(10), id: \.self) { user in
                HStack(spacing: 15) {
                    GroupIcon(size: 40, icon: String(user.first!), font: .groupIconMini2)
                    Text(user)
                        .font(.secondaryMedium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            if group.users.count > 10 {
                HStack {
                    Text("See all")
                        .font(.secondaryMedium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.secondary)
            }
        }
        .listRowBackground(Color.secondary.opacity(0.1))
    }
    
    
    private var groupProfileView: some View {
        Section {
            GroupIcon(size: 150, icon: group.groupIcon, font: .groupIcon)
                .padding(.top)
            Text(group.groupName)
                .font(.groupIconMini3)
                .foregroundColor(.primary)
            Text("Group")
                .font(.secondaryLarge)
                .foregroundColor(.secondary)
                .padding(.top, 0.5)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .hideRowSeperator()
    }
    
    private var groupCountAndSearchView: some View {
        Section {
            HStack {
                Text("\(group.users.count) Participants")
                    .font(.groupIconMini2)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .padding(10.0)
                    .foregroundColor(.secondary)
                    .overlay {
                        Circle().fill(Color.secondary.opacity(0.1))
                    }
            }
        }
        .listRowInsets(EdgeInsets())
        .hideRowSeperator()
    }
    
    private var dangerousZone: some View {
        Section {
            Text("Clear Chat")
            Text("Exit Group")
            Text("Report Group")
        } footer: {
            VStack(alignment: .leading) {
                Text("Created by \(group.adminName)")
                Text("Created on \(Date(milliseconds: group.dateCreated).customFormat)")
            }
            .foregroundColor(.secondary)
            .font(.secondaryTextMini)
        }
        .foregroundColor(.red)
        .listRowBackground(Color.secondary.opacity(0.1))
    }
    
    private func formLabel(_ text: String,
                           icon: String,
                           color: Color = .yellow,
                           isEnc: Bool = false, badge: String? = nil) -> some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 7)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .imageScale(.medium)
                }
            VStack(alignment: .leading, spacing: 6) {
                Text(text)
                if isEnc {
                    Text("Messages and calls are end-to-end encrypted.\nTap to learn more.")
                        .foregroundColor(.secondary)
                        .font(.secondaryTextMini)
                }
            }
            Spacer()
            HStack {
                if let badge = badge {
                    if badge != "0" {
                        Text(badge)
                    }
                }
                Image(systemName: "chevron.right")
            }.foregroundColor(.secondary)
        }
        .font(.secondaryMedium)
        
    }
    
    private func iconText(_ text: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .imageScale(.large)
                .bold()
            Text(text)
                .font(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .cornerRadius(12.0)
        .foregroundColor(.accentColor)
    }
}

struct GroupInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GroupInfoView(userVm: UserSocketViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
