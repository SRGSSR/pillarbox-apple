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
            .padding(.horizontal)
        }
        .overlay(alignment: .topTrailing) {
            PiPButton()
                .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
    }
}

struct TransitionPiPView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    @State private var supportsPictureInPicture = true
    @State private var isPresented = false

    var body: some View {
        VStack {
            VideoView(player: model.player)
                .supportsPictureInPicture(supportsPictureInPicture)
                .accessibilityAddTraits(.isButton)
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $supportsPictureInPicture)
                HStack {
                    Button(action: model.player.togglePlayPause) {
                        Text("Play / pause")
                    }
                    Spacer()
                    Button(action: openModal) {
                        Text("Open modal")
                    }
                }
            }
            .padding(.horizontal)
        }
        .overlay(alignment: .topTrailing) {
            PiPButton()
                .padding()
        }
        .onAppear(perform: play)
        .fullScreenCover(isPresented: $isPresented) {
            PresentedView(player: model.player)
        }
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "transition-advanced-pip")
    }

    private func play() {
        model.media = media
        model.play()
    }

    private func openModal() {
        isPresented.toggle()
    }
}

extension TransitionPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
