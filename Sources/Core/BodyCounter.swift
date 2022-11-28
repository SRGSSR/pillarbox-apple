//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

private struct BodyCounterView: UIViewRepresentable {
    let id = UUID()         // Force the view to be updated again
    let color: UIColor

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
    var color: UIColor = .clear {
        didSet {
            label.backgroundColor = color
            layer.borderColor = color.cgColor
        }
    }

    private var label = UILabel()

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
    /// Decorate the view with a bordered debugging frame whose attached label displays how many times the view
    /// body has been evaluated.
    /// - Parameters:
    ///   - color: The frame and label color.
    func _debugBodyCounter(
        color: UIColor = .red
    ) -> some View {
        overlay {
            BodyCounterView(color: color)
                .allowsHitTesting(false)
        }
    }
}
