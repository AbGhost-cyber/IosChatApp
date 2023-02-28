//
//  AsyncButton.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/27.
//  Reference URL: https://www.swiftbysundell.com/articles/building-an-async-swiftui-button/
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    var action: () async throws -> Void
    var actionOptions = Set(ActionOption.allCases)
    @ViewBuilder var label: () -> Label
    
    @State private var isDisabled = false
    @State private var showProgressView = false
    
    var body: some View {
        Button(
            action: {
                if actionOptions.contains(.disableButton) {
                    isDisabled = true
                }
                
                Task {
                    var progressViewTask: Task<Void, Error>?
                    if actionOptions.contains(.showProgressView) {
                        progressViewTask = Task {
                            try await Task.sleep(nanoseconds: 150_000_000)
                            showProgressView = true
                        }
                    }
                    try await Task.sleep(for: .seconds(1))
                    try await action()
                    
                    progressViewTask?.cancel()
                    
                    isDisabled = false
                    showProgressView = false
                }
            },
            label: {
                ZStack {
                    label().opacity(showProgressView ? 0 : 1)
                    
                    if showProgressView {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isDisabled)
    }
}
