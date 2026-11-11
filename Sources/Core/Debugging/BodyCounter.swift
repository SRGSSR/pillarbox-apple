//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

private struct BodyCounterView: UIViewRepresentable {
    let color: UIColor
    let label: String?

    private let id = UUID()         // Force view updates

    func makeUIView(context: Context) -> _BodyCounterView {
        let view = _BodyCounterView()
        view.color = color
        view.label = label
        return view
    }

    func updateUIView(_ uiView: _BodyCounterView, context: Context) {
        uiView.count += 1
    }
}

private class _BodyCounterView: UIView {
    private let countLabel = UILabel()

    var color: UIColor = .clear {
        didSet {
            countLabel.backgroundColor = color
            layer.borderColor = color.cgColor
        }
    }

    var label: String? {
        didSet {
            updateText()
        }
    }

    var count: Int = 0 {
        didSet {
            updateText()
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

    private func updateText() {
        if let label {
            countLabel.text = " \(label): \(count) "
        }
        else {
            countLabel.text = " \(count) "
        }
    }

    private func configureBorder() {
        layer.borderWidth = 2
    }

    private func configureLabel() {
        countLabel.textColor = .white
        addSubview(countLabel)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

public extension View {
    private var isDebuggingEnabled: Bool {
        ProcessInfo.processInfo.environment["PILLARBOX_DEBUG_BODY_COUNTER"] != nil
    }

    private var shouldPlayInXcodePreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }

    @ContentBuilder
    private func debugBodyCounterOverlay(color: UIColor, label: String?) -> some View {
        if isDebuggingEnabled || shouldPlayInXcodePreviews {
            BodyCounterView(color: color, label: label)
                .allowsHitTesting(false)
        }
    }

    /// Decorates the view with a bordered debugging frame whose attached label displays how many times the view
    /// body has been evaluated.
    ///
    /// - Parameters:
    ///   - color: The frame color.
    ///   - label: An optional label displayed before the count.
    ///
    /// This feature is only available in debug builds and requires the application to be run with the
    /// `PILLARBOX_DEBUG_BODY_COUNTER` environment variable set.
    ///
    /// This feature is always automatically enabled in Xcode previews.
    func _debugBodyCounter(color: UIColor = .red, label: String? = nil) -> some View {
#if DEBUG
        overlay(debugBodyCounterOverlay(color: color, label: label))
#else
        self
#endif
    }
}
