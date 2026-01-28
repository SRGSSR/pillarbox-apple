//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
struct MediaSelectionMenuContent: View {
    let characteristic: AVMediaCharacteristic
    let action: (MediaSelectionOption) -> Void

    @ObservedObject var player: Player

    var body: some View {
        SwiftUI.Picker(selection: selection(for: characteristic)) {
            ForEach(mediaOptions, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)
    }

    private var mediaOptions: [MediaSelectionOption] {
        player.mediaSelectionOptions(for: characteristic)
    }

    private func selection(for characteristic: AVMediaCharacteristic) -> Binding<MediaSelectionOption> {
        .init {
            player.mediaOption(for: characteristic).wrappedValue
        } set: { newValue in
            player.mediaOption(for: characteristic).wrappedValue = newValue
            action(newValue)
        }
    }
}
