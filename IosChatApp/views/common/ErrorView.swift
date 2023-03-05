//
//  ErrorView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/5.
//

import SwiftUI

struct ErrorView: View {
    let msg: String
    let action: (()-> Void)
    @State private var isPerforming: Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(msg.isEmpty ? "an unknown error occurred" : msg)
                .font(.secondaryMedium)
                .foregroundColor(Color.primary)
            AsyncButton {
                self.isPerforming = true
                action()
                self.isPerforming = false
            } label: {
                ZStack {
                    if isPerforming {
                        Text("Retry").hidden()
                        ProgressView()
                    } else {
                        Text("Retry")
                    }
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .embedZstack()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(msg: "An unknown error occurred") {
            
        }
    }
}
