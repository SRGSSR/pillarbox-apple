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
            HStack {
                Text("GitHub")
            }
        }
        .tint(.secondary)
    }
}

protocol SourceCodeViewable {
    static var filePath: String { get }
}

extension View {
    @ViewBuilder
    func sourceCode(of objectType: (any SourceCodeViewable.Type)?) -> some View {
#if os(iOS)
        if let objectType, let url = gitHubUrl(for: objectType) {
            swipeActions {
                SourceCodeButton {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

    private func gitHubUrl(for objectType: any SourceCodeViewable.Type) -> URL? {
        guard let relativePath = objectType.filePath.split(separator: "pillarbox-apple").last else { return nil }
        var url = URL("github://github.com/SRGSSR/pillarbox-apple/blob/main").appending(path: relativePath)
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }
}
