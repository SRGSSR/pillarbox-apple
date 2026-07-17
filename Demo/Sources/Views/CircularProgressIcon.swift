//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct CircularProgressStyle: ProgressViewStyle {
    let color: Color
    let width: Double

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.5), lineWidth: width)

            Circle()
                .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

/*
 TODO: Starting with iOS 26, should be replaced by something like:
 ```swift
 Button {} label: {
     Image(systemName: "play.circle", variableValue: 0.5)
         .symbolVariableValueMode(.draw)
 ```
 }
 */
struct CircularProgressIcon: View {
    let progress: Double
    let icon: String
    let color: Color
    let side: CGFloat

    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(CircularProgressStyle(color: color, width: side * 0.1))
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: side / 2))
                    .foregroundStyle(color)
                    .bold()
            }
            .frame(width: side, height: side)
    }

    init(progress: Double, icon: String, color: Color = .accentColor, side: CGFloat) {
        self.progress = progress
        self.icon = icon
        self.color = color
        self.side = side
    }
}

#Preview {
    VStack(spacing: 50) {
        CircularProgressIcon(progress: 0.7, icon: "play.fill", side: 100)
        CircularProgressIcon(progress: 0.3, icon: "pause.fill", color: .green, side: 100)
    }
}
