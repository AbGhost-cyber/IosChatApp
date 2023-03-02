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
        GeometryReader { proxy in
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView(showsIndicators: false) {
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
                                .padding(.top, 0.5)
                            HStack {
                                iconText("audio", icon: "phone.fill")
                                iconText("video", icon: "video.fill")
                                iconText("search", icon: "magnifyingglass")
                            }
                            .padding([.horizontal, .top])
                            //.padding()
                            
                            //MARK: group description
                            ExpandableText(group.groupDesc, lineLimit: 3)
                                .font(.secondaryMedium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: 50)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12.0)
                                .padding(.horizontal)
                                .padding(.top, 5)
                            
                            //MARK: form
                            groupForm(group: group)
                                .scrollContentBackground(.hidden)
                                .frame(height: proxy.size.height / 1.35)
                                .scrollDisabled(true)
                            
                            //MARK: search group
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
                            .padding(.horizontal)
                            
                            List(group.users, id: \.self) { user in
                                HStack(spacing: 15) {
                                    GroupIcon(size: 40, icon: String(user.first!), font: .groupIconMini2)
                                    Text(user)
                                        .font(.primaryBold)
                                }
                                .listRowBackground(Color.secondary.opacity(0.1))
                            }
                            .frame(height: proxy.size.height)
                            .offset(y: -30)
                            .scrollContentBackground(.hidden)
                        }
                    }
                    
                }
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Group info")
                        .font(.primaryBold)
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
    }
    
    
    private func groupForm(group: Group) -> some View {
        Form {
            if group.currentUserIsAdmin {
                Section {
                    formLabel("Group Requests", icon: "bell.fill", color: .mint)
                } footer: {
                    Text("check here often to view those who are interested in joining your group:)")
                        
                }
                .listRowBackground(Color.secondary.opacity(0.1))
            }
            
            Section {
                formLabel("Starred Messages", icon: "star.fill")
            }
            .listRowBackground(Color.secondary.opacity(0.1))
            
            Section {
                formLabel("Mute", icon: "speaker.slash", color: .accentColor)
                formLabel("Wallpaper & Sound", icon: "text.below.photo.fill", color: .pink)
            }.listRowBackground(Color.secondary.opacity(0.1))
            
            Section {
                formLabel("Encryption", icon: "lock.fill", color: .accentColor, isEnc: true)
            }
            .listRowBackground(Color.secondary.opacity(0.1))
        }
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
                    Text(badge)
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
        .background(Color.secondary.opacity(0.1))
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
