//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "chevron.down")
                    .tint(.white)
                    .frame(width: 45, height: 45)
            }
            .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 1)
        default:
            EmptyView()
        }
    }
}
