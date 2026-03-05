//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams
import XCTest

final class DownloadTests: TestCase {
    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: ""),
        assetDownloadDelegate: nil,
        delegateQueue: nil
    )

    func testCreation() {
        let download = Download(url: Stream.shortOnDemand.url, session: session)
        expect(download.state).toEventually(equal(.running))
    }

    func testCompleted() {
        let download = Download(url: Stream.shortOnDemand.url, session: session)
        expect(download.state).toEventually(equal(.completed))
    }
}
