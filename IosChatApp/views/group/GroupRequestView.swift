//
//  GroupRequestView.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/3/4.
//

import SwiftUI

struct GroupRequestView: View {
    @ObservedObject var userVm: UserSocketViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var selections: Set<JoinRequestIncoming> = []
    @State private var showActions = false
    @State private var requests: [JoinRequestIncoming] = []
    @State private var hasError: Bool = false
    
    var body: some View {
        NavigationStack {
            requestList
            .background(Color.secondary.opacity(0.1))
            .listStyle(.plain)
            .navigationTitle("Group Requests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(isEditing ? "Done" : "Edit")
                        .bold(isEditing)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if isEditing && !selections.isEmpty {
                                showActions = true
                                return
                            }
                            isEditing.toggle()
                        }
                }
                ToolbarItem {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let selectedGroup = userVm.selectedGroup {
                    requests = selectedGroup.requests
                }
            }
            .alert("Error", isPresented: $hasError) {
                Button(role: .cancel, action: {}) {
                    Text("OK")
                }
            } message: {
                Text(userVm.userMessage)
                    .font(.secondaryText)
            }
            .confirmationDialog("Choose Action", isPresented: $showActions) {
                Button("Accept request") {
                    handleRequest(.accept)
                }
                Button("Reject request") {
                    handleRequest(.reject)
                }
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("Choose what action to perform")
            }
        }
    }
    
    private func handleRequest(_ action: RequestAction) {
        if selections.isEmpty { return }
        var updatedRequests:[JoinRequestIncoming] = []
        Task {
            for request in selections {
              updatedRequests = await userVm.handleAdminGroupRequest(
                with: action, joinReq: request
              )
            }
            self.isEditing = false
            if !userVm.hasError {
                self.requests = updatedRequests
                if let group = userVm.selectedGroup {
                    for selection in selections {
                        userVm.message = "\(selection.username) was added to the group by Admin \(group.adminName)"
                        await userVm.sendMessage(with: group.groupId, isNotification: true)
                    }
                    self.selections = []
                }
               await userVm.fetchGroups()
            }
        }
    }
    
    
    private var requestList: some View {
        List(requests, id: \.username) { request in
            let isSelected = selections.contains(request)
            let icon = isSelected ? "checkmark.circle.fill" : "circle"
            HStack {
                if isEditing {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if isSelected {
                                selections.remove(request)
                            }else {
                                selections.insert(request)
                            }
                        }
                }
                Text(request.username)
                    .font(.welcomeDesc)
                    .padding()
                    .animation(.linear, value: isEditing)
            }
            .listRowBackground(Color.clear)
        }.overlay {
            if requests.isEmpty {
                NoItemView(text: "those interested in joining your \ngroup will appear here 🤙🏾")
            }
        }
    }
}


struct GroupRequestView_Previews: PreviewProvider {
    static var previews: some View {
        GroupRequestView(userVm: .init())
            .preferredColorScheme(.dark)
    }
}
