//
//  NoItemView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import SwiftUI

struct NoItemView: View {
    var text: String = "No data available"
    var body: some View {
        Text(text)
            .font(.secondaryText)
            .foregroundColor(Color(uiColor: .secondaryLabel))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .embedZstack()
    }
}

struct NoItemView_Previews: PreviewProvider {
    static var previews: some View {
        NoItemView()
            .preferredColorScheme(.light)
    }
}
