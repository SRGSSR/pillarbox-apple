//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderModel

final class MediaListViewModel: ObservableObject {
    private let dataProvider = DataPr
    @Published var medias: [SRGMedia] = []

    init() {

    }
}
