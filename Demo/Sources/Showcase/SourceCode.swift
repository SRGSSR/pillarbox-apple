//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SourceCodeButton: View {
    let perform: () -> Void

    var body: some View {
        Button {
            perform()
        } label: {
            Image(systemName: "globe")
        }
        .tint(.secondary)
    }
}

protocol SourceCode {
    static var filePath: String { get }
}

extension View {
    @ViewBuilder
    func sourceCode(of objectType: (any SourceCode.Type)?) -> some View {
        if
            let objectType,
            let relativePath = objectType.filePath.split(separator: "pillarbox-apple").last {
            let url = URL("https://github.com/SRGSSR/pillarbox-apple/blob/main").appending(path: relativePath)
            swipeActions {
                SourceCodeButton {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        else {
            self
        }
    }
}
