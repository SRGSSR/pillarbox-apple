//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

extension Asset {
    static func tokenProtected(url: URL, metadata: M, configuration: PlaybackConfiguration) -> Self {
        let id = UUID()
        return .custom(
            url: AkamaiURLCoding.encodeUrl(url, id: id),
            delegate: AkamaiResourceLoaderDelegate(id: id),
            metadata: metadata,
            configuration: configuration
        )
    }

    static func encrypted(url: URL, certificateUrl: URL, metadata: M, configuration: PlaybackConfiguration) -> Self {
        // FIXME: An issue affects `AVContentKeySession`, preventing key request creation after several hours (FB19383686).
        //        In the meantime we use a `.custom` asset but when the issue has been fixed we should use an `.encrypted`
        //        asset (removing `IrdetoResourceLoaderDelegate` in the process).
        // .encrypted(
        //     url: url,
        //     delegate: IrdetoContentKeySessionDelegate(certificateUrl: certificateUrl),
        //     metadata: metadata,
        //     configuration: configuration
        // )
        .custom(
            url: url,
            delegate: IrdetoResourceLoaderDelegate(certificateUrl: certificateUrl),
            metadata: metadata,
            configuration: configuration
        )
    }
}
