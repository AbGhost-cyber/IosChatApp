//
//  CTextField.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import SwiftUI

struct CTextField: View {
    @Binding var value: String
    let hint: String
    var body: some View {
        TextField(hint, text: $value, axis: .vertical)
            .padding(10)
            .font(.secondaryMedium)
            .frame(minHeight: 60)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(10.0)
    }
}

struct CTextField_Previews: PreviewProvider {
    static var previews: some View {
        CTextField(value: .constant("hello"), hint: "Username")
    }
}
