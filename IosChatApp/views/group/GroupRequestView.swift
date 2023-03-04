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
   // @State private var icon = "circle"
    @State private var selections: Set<String> = []
    @State private var showActions = false
    @State private var requests: [JoinRequestIncoming] = []
    
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
            .confirmationDialog("Choose Action", isPresented: $showActions) {
                Button("Accept request") {
                    
                }
                Button("Reject request") {
                    
                }
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("Choose what action to perform")
            }
        }
    }
    
    
    private var requestList: some View {
        List(requests, id: \.username) { request in
            let isSelected = selections.contains(request.username)
            let icon = isSelected ? "checkmark.circle.fill" : "circle"
            HStack {
                if isEditing {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if isSelected {
                                selections.remove(request.username)
                            }else {
                                selections.insert(request.username)
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
