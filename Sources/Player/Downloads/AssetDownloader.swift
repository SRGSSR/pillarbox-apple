//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public final class AssetDownloader: ObservableObject {
    @Published public private(set) var downloads: [AssetDownload] = []

    public func removeDownload(_ download: AssetDownload) {

    }

    public func addDownload<P, M>(publisher: P) where P: Publisher, P.Output == Asset<M>, M: AssetMetadata {

    }
}

public extension AssetDownloader {
    func addDownload<M>(asset: Asset<M>) where M: AssetMetadata {

    }

    func addSimpleDownload<M>(url: URL, metadata: M) where M: AssetMetadata {

    }
}
