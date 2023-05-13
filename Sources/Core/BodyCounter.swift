//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

private struct BodyCounterView: UIViewRepresentable {
    let color: UIColor

    private let id = UUID()         // Force view updates

    func makeUIView(context: Context) -> _BodyCounterView {
        let view = _BodyCounterView()
        view.color = color
        return view
    }

    func updateUIView(_ uiView: _BodyCounterView, context: Context) {
        uiView.count += 1
    }
}

private class _BodyCounterView: UIView {
    private var label = UILabel()

    var color: UIColor = .clear {
        didSet {
            label.backgroundColor = color
            layer.borderColor = color.cgColor
        }
    }

    var count: Int = 0 {
        didSet {
            label.text = " \(count) "
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBorder()
        configureLabel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureBorder() {
        layer.borderWidth = 2
    }

    private func configureLabel() {
        label.textColor = .white
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

public extension View {
    @ViewBuilder
    private func debugBodyCounterOverlay(color: UIColor) -> some View {
        if ProcessInfo.processInfo.environment["PILLARBOX_DEBUG_BODY_COUNTER"] != nil {
            BodyCounterView(color: color)
                .allowsHitTesting(false)
        }
    }

    /// Decorate the view with a bordered debugging frame whose attached label displays how many times the view
    /// body has been evaluated.
    ///
    /// This feature is only available in debug builds and requires the application to be run with the
    /// `PILLARBOX_DEBUG_BODY_COUNTER` environment variable set.
    ///
    /// - Parameters:
    ///   - color: The frame and label color.
    func _debugBodyCounter(color: UIColor = .red) -> some View {
#if DEBUG
        overlay(debugBodyCounterOverlay(color: color))
#else
        self
#endif
    }
}
