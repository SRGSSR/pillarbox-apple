//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PickerMenu<Content, Selection>: View where Content: View, Selection: Hashable & CustomLocalizedStringResourceConvertible {
    private let titleKey: LocalizedStringKey
    private let selection: Binding<Selection>
    private let content: () -> Content

    var body: some View {
#if os(tvOS)
        if #available(tvOS 17, *) {
            Menu {
                Picker(titleKey, selection: selection, content: content)
            } label: {
                LabeledContent(titleKey, value: String(localized: selection.wrappedValue.localizedStringResource))
            }
        }
        else {
            Picker(titleKey, selection: selection, content: content)
                .pickerStyle(.navigationLink)
        }
#else
        Picker(titleKey, selection: selection, content: content)
#endif
    }

    init(_ titleKey: LocalizedStringKey, selection: Binding<Selection>, @ContentBuilder content: @escaping () -> Content) {
        self.titleKey = titleKey
        self.selection = selection
        self.content = content
    }
}
