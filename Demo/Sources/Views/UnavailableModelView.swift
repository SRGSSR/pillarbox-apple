//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

protocol Refreshable {
    func refresh() async
}

struct UnavailableModelView<Model, Label, Description>: View where Model: Refreshable, Label: View, Description: View {
    let model: Model
    let label: () -> Label
    let description: () -> Description

    var body: some View {
#if os(iOS)
        GeometryReader { geometry in
            ScrollView {
                UnavailableView(label: label, description: description)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
#else
        UnavailableView(label: label, description: description)
#endif
    }

    init(model: Model, label: @escaping () -> Label, description: @escaping () -> Description = { EmptyView() }) {
        self.model = model
        self.label = label
        self.description = description
    }
}

#Preview {
    UnavailableModelView(model: SearchViewModel()) {
        Label {
            Text(verbatim: "title")
        } icon: {
            Image(systemName: "circle.fill")
        }
    } description: {
        Text(verbatim: "description")
    }
}
