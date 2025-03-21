//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

protocol Refreshable {
    func refresh() async
}

enum MessageIcon {
    case none
    case error
    case empty
    case system(String)

    var systemName: String? {
        switch self {
        case .none:
            return nil
        case .error:
            return "exclamationmark.bubble"
        case .empty:
            return "circle.slash"
        case let .system(name):
            return name
        }
    }
}

struct MessageView: View {
    let message: String
    let icon: MessageIcon

    var body: some View {
        VStack(spacing: 16) {
            if let systemName = icon.systemName {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
                    .frame(height: 40)
            }
            Text(message)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
#if os(tvOS)
        .focusable()
#endif
    }
}

#Preview("None") {
    MessageView(message: "No items", icon: .none)
}

#Preview("Error") {
    MessageView(message: "No items", icon: .error)
}

#Preview("Empty") {
    MessageView(message: "No items", icon: .empty)
}

#Preview("System") {
    MessageView(message: "Not connected", icon: .system("wifi"))
}
