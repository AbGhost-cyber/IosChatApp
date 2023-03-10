//
//  CreateGroupView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/22.
//

import SwiftUI
struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupIcon = ""
    @State private var groupName = ""
    @State private var groupDesc = ""
    @ObservedObject var userVm: UserSocketViewModel
    @State private var isClicked = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.primary.opacity(0.1))
                    .ignoresSafeArea(.all)
                ScrollView {
                    Circle()
                        .frame(width: 200)
                        .scaledToFit()
                        .padding()
                        .foregroundColor(.purple.opacity(0.3))
                        .overlay {
                            TextField("", text: $groupIcon.max(1))
                                .font(.groupIcon)
                                .lineLimit(1)
                                .fixedSize()
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Circle()
                                .fill(.purple)
                                .frame(width: 30)
                                .overlay {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.white)
                                }
                                .offset(x: -25, y: -30)
                        }
                    //MARK: Group name
                    CTextField(value: $groupName, hint: "Group name")
                        .onChange(of: groupName) { newValue in
                            if groupIcon.isEmpty && !newValue.isEmpty{
                                groupIcon = String(newValue.first!)
                            }
                        }
                    CTextField(value: $groupDesc, hint: "Group Description")
                    Divider()
                        .padding(.top)
                    userView
                        .padding(.top)
                }.padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }.foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncButton(action: {
                        try await userVm.createGroup(
                            name: groupName,
                            desc: groupDesc,
                            icon: groupIcon)
                        dismiss()
                    }, label: {
                        Text("Create")
                    })
                    .disabled(groupDesc.isEmpty || groupIcon.isEmpty || groupName.isEmpty)
                }
            }
            .alert("Group Create Error ???", isPresented: $userVm.hasError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(userVm.userMessage)
                    .font(.secondaryText)
            })
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private var userView: some View {
        HStack {
            Circle()
                .fill(Color.cyan)
                .frame(width: 50, height: 50)
                .padding(.leading)
            VStack(alignment: .leading) {
                Text("You")
                    .font(.primaryBold)
                Text("last seen recently")
                    .font(.secondaryText)
                    .foregroundColor(.gray)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(12.0)
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView(userVm: UserSocketViewModel())
    }
}
