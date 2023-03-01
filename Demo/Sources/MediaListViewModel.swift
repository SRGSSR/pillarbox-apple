//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderModel

final class MediaListViewModel: ObservableObject {
    @Published var medias: [SRGMedia] = []
}
