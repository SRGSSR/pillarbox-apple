//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SettingsMenuView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        Menu(content: content) {
            Image(systemName: "ellipsis.circle")
                .tint(.white)
        }
    }
}

private struct PlaybackSpeedMenuView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        Menu(content: content) {
            HStack {
                Text("Playback Speed")
                Image(systemName: "speedometer")
            }
        }
    }
}

private struct PlaybackSpeedButton: View {
    let speed: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isSelected {
                Image(systemName: "checkmark")
            }
            Text(String(format: "%.2fx", speed))
        }
    }
}

struct PlaybackSpeedView: View {
    var body: some View {
        SettingsMenuView {
            PlaybackSpeedMenuView {
                EmptyView()
            }
        }
    }
}

struct PlaybackSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSpeedView()
            .background(.black)
    }
}
