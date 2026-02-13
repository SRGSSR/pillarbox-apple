//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Nimble
import PillarboxPlayer

@_spi(StandardConnectorPrivate)
@testable import PillarboxStandardConnector

import XCTest

private enum ErrorMock: Error, Equatable {
    case unknown
}

final class PlayerItemTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    override func tearDown() {
        URLProtocol.registerClass(URLProtocolMock.self)
        URLProtocolMock.responseHandler = nil
        super.tearDown()
    }

    func testHttpError() {
        URLProtocolMock.responseHandler = { request in
            HttpResponseHandler(
                data: nil,
                response: HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil),
                error: nil
            )
        }

        let playerItem = PlayerItem.standard(request: URLRequest(url: URL(string: "https://standard.connector.pillarbox.ch")!)) { playerData in
            Asset.unavailable(with: ErrorMock.unknown, metadata: playerData)
        }

        let player = Player(item: playerItem)
        expect { (player.error as? HttpError)?.statusCode }.toEventually(equal(404))
    }

    func testBusinessError() {
        URLProtocolMock.responseHandler = { request in
            HttpResponseHandler(
                data: Data("{}".utf8),
                response: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                error: nil
            )
        }

        let playerItem = PlayerItem.standard(request: URLRequest(url: URL(string: "https://standard.connector.pillarbox.ch")!)) { playerData in
            Asset.unavailable(with: ErrorMock.unknown, metadata: playerData)
        }

        let player = Player(item: playerItem)
        expect { player.error as? ErrorMock }.toEventually(equal(.unknown))
    }

    func testSourceError() {
        URLProtocolMock.responseHandler = { request in
            HttpResponseHandler(
                data: Data(),
                response: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                error: nil
            )
        }

        let playerItem = PlayerItem.standard(request: URLRequest(url: URL(string: "https://standard.connector.pillarbox.ch")!)) { playerData in
            Asset.unavailable(with: ErrorMock.unknown, metadata: playerData)
        }

        let player = Player(item: playerItem)
        expect { player.error as? SourceError }.toEventuallyNot(beNil())
    }
}
