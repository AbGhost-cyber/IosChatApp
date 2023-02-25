//
//  GroupIcon.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/25.
//

import SwiftUI

struct GroupIcon: View {
    let size: CGFloat
    let icon: String
    let font: Font
    var body: some View {
        Circle()
            .fill(Color.mint)
            .frame(width: size, height: size)
            .overlay {
                Text(icon)
                    .font(font)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
    }
}

struct GroupIcon_Previews: PreviewProvider {
    static var previews: some View {
        GroupIcon(size: 65, icon: "🧕🏿", font: .groupIconMini)
    }
}
