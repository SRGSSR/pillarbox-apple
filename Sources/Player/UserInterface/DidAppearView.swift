//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

private  final class DidAppearViewController: UIViewController {
    var action: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        action?()
    }
}

private struct DidAppearView: UIViewControllerRepresentable {
    let action: () -> Void

    func makeUIViewController(context: Context) -> DidAppearViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: DidAppearViewController, context: Context) {
        uiViewController.action = action
    }
}

extension View {
    func onDidAppear(perform action: @escaping () -> Void) -> some View {
        background {
            DidAppearView(action: action)
        }
    }
}
