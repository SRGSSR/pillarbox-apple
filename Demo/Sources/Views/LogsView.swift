//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct LogsView: View {
    @ObservedObject var player: Player
    @State private var logs: PlayerItemLogs?

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if let logs {
                    Text(verbatim: logs.prettyPrinted)
                        .textStyle(background: .yellow)
                    if let errorLog = logs.lastErrorEventLog {
                        Text(verbatim: errorLog.info)
                            .textStyle(background: .red)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height / 2)
            .offset(y: geometry.size.height / 2)
        }
        .allowsHitTesting(false)
        .onReceive(player: player, assign: \.logs, to: $logs)
    }
}

private extension Text {
    func textStyle(background: Color) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(30)
            .foregroundStyle(.white)
            .background(background.opacity(0.3))
            .font(.title3)
            .fontWeight(.bold)
            .shadow(radius: 5)
            .minimumScaleFactor(0.3)
    }
}
