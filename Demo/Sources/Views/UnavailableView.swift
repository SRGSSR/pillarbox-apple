//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use `SwiftUI.ContentUnavailableView`")
@available(tvOS, introduced: 16.0, deprecated: 17.0, message: "Use `SwiftUI.ContentUnavailableView`")
private struct ContentUnavailableViewIOS16<Label, Description>: View where Label: View, Description: View {
    let label: () -> Label
    let description: () -> Description

    var body: some View {
        VStack(spacing: 4) {
            title()
            subtitle()
        }
        .padding(.top, 15)
        .padding([.horizontal, .bottom], 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder description: @escaping () -> Description) {
        self.label = label
        self.description = description
    }

    private func title() -> some View {
        label()
            .labelStyle(TitleLabelStyle())
    }

    private func subtitle() -> some View {
        description()
            .font(.callout)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
    }
}

private struct TitleLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 16) {
            configuration.icon
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            configuration.title
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }
}

struct UnavailableView<Label, Description>: View where Label: View, Description: View {
    let label: () -> Label
    let description: () -> Description

    var body: some View {
        if #available(iOS 17.0, tvOS 17.0, *) {
            ContentUnavailableView(label: label, description: description)
        }
        else {
            ContentUnavailableViewIOS16(label: label, description: description)
        }
    }

    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() }
    ) {
        self.label = label
        self.description = description
    }
}

#Preview("iOS 16.0") {
    ContentUnavailableViewIOS16 {
        Label {
            Text(verbatim: "title")
        } icon: {
            Image(systemName: "circle.fill")
        }
    } description: {
        Text(verbatim: "description")
    }
}

@available(iOS 17, tvOS 17, *)
#Preview("iOS 17.0+") {
    ContentUnavailableView {
        Label {
            Text(verbatim: "title")
        } icon: {
            Image(systemName: "circle.fill")
        }
    } description: {
        Text(verbatim: "description")
    }
}
