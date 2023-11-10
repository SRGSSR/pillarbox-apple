//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

private  final class WillAppearViewController: UIViewController {
    var action: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        action?()
    }
}

private struct WillAppearView: UIViewControllerRepresentable {
    let action: () -> Void

    func makeUIViewController(context: Context) -> WillAppearViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: WillAppearViewController, context: Context) {
        uiViewController.action = action
    }
}

extension View {
    func onWillAppear(perform action: @escaping () -> Void) -> some View {
        background {
            WillAppearView(action: action)
        }
    }
}
