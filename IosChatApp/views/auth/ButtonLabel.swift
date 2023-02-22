//
//  ButtonLabel.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import Foundation
import SwiftUI

struct ButtonLabel: View {
    let text: String
    let isLoading: Bool
    var body: some View {
        VStack {
            Text(text)
                .font(.secondaryMedium)
                .fontWeight(.black)
                .opacity(isLoading ? 0 : 1)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(Color.yellow.opacity(0.6))
        .foregroundColor(.black)
        .cornerRadius(12.0)
        .padding(.top)
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
                    .padding(.top, 10)
            }
        }
    }
}

