//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public struct PictureInPictureButton<Content>: View where Content: View {
    private let content: (Bool) -> Content
    @State private var isActive = false

    public init(@ViewBuilder content: @escaping (_ isActive: Bool) -> Content) {
        self.content = content
    }

    public var body: some View {
        Button(action: PictureInPicture.shared.toggle) {
            content(isActive)
        }
        .onReceive(PictureInPicture.shared.$isActive) { isActive = $0 }
    }
}
