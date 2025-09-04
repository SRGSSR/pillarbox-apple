//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

protocol Refreshable {
    func refresh() async
}

struct UnavailableRefreshableView<Model, Label, Description>: View where Model: Refreshable, Label: View, Description: View {
    let model: Model
    let label: () -> Label
    let description: () -> Description

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                UnavailableView(label: label, description: description)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
#if os(tvOS)
        .focusable()
#endif
    }

    init(model: Model, label: @escaping () -> Label, description: @escaping () -> Description = { EmptyView() }) {
        self.model = model
        self.label = label
        self.description = description
    }
}
