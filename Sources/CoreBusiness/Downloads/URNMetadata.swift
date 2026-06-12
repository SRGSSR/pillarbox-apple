//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct URNMetadata {
    let identifier: String?
    let title: String?
    let subtitle: String?
    let analyticsData: [String: String]
    let analyticsMetadata: [String: String]

    @available(iOS 17.0, *)
    var entryMetadata: URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            analyticsData: analyticsData,
            analyticsMetadata: analyticsMetadata
        )
    }
}

#endif

// swiftlint:enable missing_docs
