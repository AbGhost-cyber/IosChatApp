//
//  GroupChatView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/25.
//

import SwiftUI

struct GroupChatView: View {
    let group: Group
    var body: some View {
        ZStack {
            Rectangle().fill(Color.primary.opacity(0.1))
                .ignoresSafeArea(.all)
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(group.groupName)
                        .foregroundColor(.primary)
                        .font(.primaryBold2)
                }
                ToolbarItem {
                    GroupIcon(size: 45, icon: group.groupIcon, font: .groupIconMini2)
                }
            }
        }
    }
}

struct GroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatView(group: Group.stub[0])
    }
}
