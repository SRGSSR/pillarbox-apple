//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private enum BodyCounterRecorder {
    private static var counts: [String: UInt] = [:]

    static func recordBodyUpdate(for identifier: String) {
        if let count = counts[identifier] {
            counts[identifier] = count + 1
        }
        else {
            counts[identifier] = 1
        }
    }

    static func recordDisappearance(for identifier: String) {
        counts[identifier] = nil
    }

    static func count(for identifier: String) -> UInt {
        counts[identifier] ?? 0
    }
}

private struct BodyCounter: View {
    let identifier: String
    let color: Color

    var body: some View {
        Text(String(BodyCounterRecorder.count(for: identifier)))
            .font(.system(size: 14))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .foregroundColor(.white)
            .background(color)
            .allowsHitTesting(false)
    }
}

public extension View {
    /// Decorate the view with a bordered debugging frame whose attached label displays how many times the view
    /// body has been evaluated.
    /// - Parameters:
    ///   - color: The frame and label color
    ///   - alignment: The label alignment with the frame.
    func _debugBodyCounter(
        color: Color = .red,
        alignment: Alignment = .topTrailing,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) -> some View {
        // Use stable identifier based on where in the source code the modifier is applied.
        let identifier = "\(file)_\(line)_\(column)"
        return border(color, width: 2)
            .overlay(alignment: alignment) {
                // swiftlint:disable:next redundant_discardable_let
                let _ = BodyCounterRecorder.recordBodyUpdate(for: identifier)
                BodyCounter(identifier: identifier, color: color)
                    .id(UUID())     // Force updates
            }
            .onDisappear {
                BodyCounterRecorder.recordDisappearance(for: identifier)
            }
    }
}
