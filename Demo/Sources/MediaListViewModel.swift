//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderCombine
import SRGDataProviderModel

final class MediaListViewModel: ObservableObject {
    @Published var medias: [SRGMedia] = []

    init() {
        SRGDataProvider.current!.tvLatestMedias(for: .RTS)
            .replaceError(with: [])
            .receiveOnMainThread()
            .assign(to: &$medias)
    }
}
