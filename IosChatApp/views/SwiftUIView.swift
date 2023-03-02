//
//  SwiftUIView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/2.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Form {
            Section {
                Label("Starred Messages", systemImage: "star.fill")
                    .font(.secondaryMedium)
            }
            Section {
                Label("Mute", systemImage: "star.fill")
                    .font(.secondaryMedium)
                Label("Wallpaper & Sound", systemImage: "star.fill")
                    .font(.secondaryMedium)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
