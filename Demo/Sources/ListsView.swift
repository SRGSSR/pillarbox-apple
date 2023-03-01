//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

struct ListsView: View {
    var body: some View {
        NavigationStack {
            List {
                section(title: "Latest Videos", kind: .tvLatestMedias, vendors: [
                    .SRF, .RTS, .RSI, .RTR, .SWI
                ])
            }
            .navigationTitle("Lists")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func name(for vendor: SRGVendor) -> String {
        switch vendor {
        case .SRF:
            return "SRF"
        case .RTS:
            return "RTS"
        case .RSI:
            return "RSI"
        case .RTR:
            return "RTR"
        case .SWI:
            return "SWI"
        default:
            return "-"
        }
    }

    @ViewBuilder
    private func section(title: String, kind: MediaListViewModel.Kind, vendors: [SRGVendor]) -> some View {
        Section(title) {
            ForEach(vendors, id: \.self) { vendor in
                NavigationLink(Self.name(for: vendor)) {
                    MediaListView(configuration: .init(kind: kind, vendor: vendor))
                }
            }
        }
    }
}
