//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol DownloadDelegate<L>: AnyObject {
    associatedtype L: AssetLoader

    func metadata(for identifier: String) -> L.Metadata?
    func location(for identifier: String) -> URL?
    func updateDownloadRecord(_ record: DownloadRecord<L.Input, L.Metadata>, for identifier: String)
}
