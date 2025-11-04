//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SourceCodeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("Source code")
            }
        }
        .tint(.accentColor)
    }
}

protocol SourceCodeViewable {
    static var filePath: String { get }
}

extension View {
    @ViewBuilder
    func sourceCode<T>(of objectType: T.Type) -> some View where T: SourceCodeViewable {
#if os(iOS)
        if let url = sourceCodeUrl(for: objectType) {
            swipeActions {
                SourceCodeButton {
                    UIApplication.shared.open(url)
                }
            }
        }
        else {
            self
        }
#else
        self
#endif
    }

    private func sourceCodeUrl<T>(for objectType: T.Type) -> URL? where T: SourceCodeViewable {
        let separator = "/Demo/"
        guard let relativePath = objectType.filePath.split(separator: separator).last else { return nil }
        return ProjectLink.sourceCode(separator + relativePath).url
    }
}
