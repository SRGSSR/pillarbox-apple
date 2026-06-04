//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

private var kUsesContentKeySession = false

/// Sets whether encrypted assets are delivered using modern content key session APIs or legacy APIs.
///
/// > Important: This setting is reserved to the Pillarbox development team. Please never modify.
@_spi(CoreBusinessPrivate)
public func _setUsesContentKeySession(_ usesContentKeySession: Bool) {
    kUsesContentKeySession = usesContentKeySession
}

extension Asset {
    static func tokenProtected(url: URL, configuration: PlaybackConfiguration) -> Self {
        let id = UUID()
        return .custom(
            url: AkamaiURLCoding.encodeUrl(url, id: id),
            delegate: AkamaiResourceLoaderDelegate(id: id),
            configuration: configuration
        )
    }

    static func encrypted(url: URL, certificateUrl: URL, configuration: PlaybackConfiguration) -> Self {
        // FIXME: An issue affects `AVContentKeySession`, preventing key request creation after several hours (FB19383686).
        //        In the meantime we use a `.custom` asset but when the issue has been fixed we should use an `.encrypted`
        //        asset (removing `IrdetoResourceLoaderDelegate` in the process).
        if kUsesContentKeySession {
             .encrypted(
                 url: url,
                 delegate: IrdetoContentKeySessionDelegate(certificateUrl: certificateUrl),
                 configuration: configuration
             )
        }
        else {
            .custom(
                url: url,
                delegate: IrdetoResourceLoaderDelegate(certificateUrl: certificateUrl),
                configuration: configuration
            )
        }
    }
}
