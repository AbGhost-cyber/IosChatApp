//
//  WelcomeUserView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import SwiftUI

struct WelcomeUserView: View {
    @State private var sheetAction: SheetAction?
    @ObservedObject var authVm: AuthViewModel
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .ignoresSafeArea(.all)
            VStack(alignment: .center, spacing: 20) {
                Image("conversation")
                    .imageScale(.medium)
                    .padding(.top)
                Text("Hey! Welcome")
                    .font(.welcome)
                    .padding(.top, 50)
                Text("Connect with multiple people around the globe, create groups, enjoy private chatting and more!")
                    .foregroundColor(Color(uiColor: .gray))
                    .font(.welcomeDesc)
                Button {
                    sheetAction = .getStarted
                } label: {
                    buttonLabel(text: "Get Started", color: .yellow.opacity(0.6))
                }
                .padding(.top, 50)
                Button {
                    sheetAction = .hasAccount
                } label: {
                    buttonLabel(text: "I already have an account")
                }
                
            }
            .multilineTextAlignment(.center)
            .padding()
            .sheet(item: $sheetAction) { action in
                switch action {
                case .hasAccount:
                    LoginView(authVm: authVm)
                case .getStarted:
                    SignupView(authVm: authVm)
                }
            }
        }
    }
    @ViewBuilder
    private func buttonLabel(text: String, color: Color = .white) -> some View {
        Text(text)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: 55)
            .background(color)
            .font(.welcomeBtn)
            .fontWeight(.semibold)
            .cornerRadius(12.0)
    }
}

struct WelcomeUserView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeUserView(authVm: AuthViewModel())
    }
}

extension WelcomeUserView {
    enum SheetAction: Identifiable {
        case getStarted
        case hasAccount
        
        var id: Int {
            switch self {
            case .getStarted: return 1
            case .hasAccount: return 2
            }
        }
    }
}
