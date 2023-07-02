//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackSlider: View {
    let minimumValueText: String = ""
    let maximumValueText: String = ""

    @State private var valueWidth: CGFloat = 0
    @State private var bufferWidth: CGFloat = 0

    var body: some View {
        HStack {
            text(minimumValueText)
            progressBar(valueWidth: valueWidth, bufferWidth: bufferWidth)
                .gesture(dragGesture())
            text(maximumValueText)
        }
    }

    @ViewBuilder
    private func text(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fixedSize()
    }

    @ViewBuilder
    private func rectangle(opacity: Double = 1, width: CGFloat? = nil) -> some View {
        Rectangle()
            .foregroundColor(.white)
            .opacity(opacity)
            .frame(width: width)
    }

    @ViewBuilder
    private func progressBar(valueWidth: CGFloat, bufferWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            rectangle(opacity: 0.1)
            rectangle(opacity: 0.3, width: bufferWidth)
            rectangle(width: valueWidth)
        }
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                print("Dragging \(gesture.translation.width)")
            }
            .onEnded { _ in
                print("Ended")
            }
    }
}

struct PlaybackSlider_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSlider()
            .padding(.horizontal, 5)
    }
}
