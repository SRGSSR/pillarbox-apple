//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

protocol Refreshable {
    func refresh() async
}

enum MessageIcon: String {
    case error = "exclamationmark.bubble"
    case empty = "circle.slash"
    case search = "magnifyingglass"
}

struct MessageView: View {
    let message: String
    let icon: MessageIcon

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon.rawValue)
                .resizable()
                .frame(width: 90, height: 90)
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
        }
        .foregroundColor(.secondary)
    }
}

struct RefreshableMessageView<Model>: View where Model: Refreshable {
    let model: Model
    let message: String
    let icon: MessageIcon

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MessageView(message: message, icon: icon)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
    }
}
