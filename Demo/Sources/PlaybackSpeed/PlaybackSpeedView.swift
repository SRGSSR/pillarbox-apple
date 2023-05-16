//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
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
    @StateObject private var viewModel = PlaybackSpeedViewModel()
    @ObservedObject var player: Player

    var body: some View {
        SettingsMenuView {
            PlaybackSpeedMenuView {
                ForEach(viewModel.playbackSpeeds.reversed(), id: \.self) { speed in
                    PlaybackSpeedButton(speed: speed, isSelected: viewModel.playbackSpeed == speed) {
                        viewModel.updateSpeed(speed)
                    }
                }
            }
        }
        .frame(width: 45, height: 45)
        .onAppear {
            viewModel.bind(player)
        }
        .onChange(of: player) { newValue in
            viewModel.bind(newValue)
        }
    }
}

struct PlaybackSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSpeedView(player: Player())
            .background(.black)
    }
}
