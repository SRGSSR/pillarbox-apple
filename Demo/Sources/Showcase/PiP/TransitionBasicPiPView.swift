//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

private struct PresentedView: View {
    @ObservedObject var player: Player

    @State private var supportsPictureInPicture = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            VideoView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $supportsPictureInPicture)
                Button(action: player.togglePlayPause) {
                    Text("Play / pause")
                }
            }
            .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton()
                .padding(.horizontal)
                .frame(minHeight: 35)
        }
    }
}

struct TransitionBasicPiPView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    @State private var supportsPictureInPicture = true
    @State private var isPresented = false

    var body: some View {
        VStack {
            VideoView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
                .accessibilityAddTraits(.isButton)
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $supportsPictureInPicture)
                HStack {
                    Button(action: player.togglePlayPause) {
                        Text("Play / pause")
                    }
                    Spacer()
                    Button(action: openModal) {
                        Text("Open modal")
                    }
                }
            }
            .padding()
        }
        .onAppear(perform: play)
        .fullScreenCover(isPresented: $isPresented) {
            PresentedView(player: player)
        }
        .tracked(name: "transition-basic-pip")
    }

    private func play() {
        player.append(media.item())
        player.play()
    }

    private func openModal() {
        isPresented.toggle()
    }
}

extension TransitionBasicPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionBasicPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
