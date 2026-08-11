//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxStreams

@available(tvOS, unavailable)
final class DownloadSizeTests: TestCase {
    func testValid() throws {
        let size = try unwrap(DownloadSize(completed: 50, total: 100))
        expect(size.completed).to(equal(50))
        expect(size.total).to(equal(100))
    }

    func testInvalid() {
        expect(DownloadSize(completed: 50, total: 0)).to(beNil())
    }

    func testTotal() throws {
        let size = try unwrap(DownloadSize(total: 100))
        expect(size.completed).to(equal(100))
        expect(size.total).to(equal(100))
    }

    func testCompletedNeverLargerThanTotal() throws {
        let size = try unwrap(DownloadSize(completed: 150, total: 100))
        expect(size.completed).to(equal(100))
        expect(size.total).to(equal(100))
    }

    func testCompletedNeverNegative() throws {
        let size = try unwrap(DownloadSize(completed: -10, total: 100))
        expect(size.completed).to(equal(0))
        expect(size.total).to(equal(100))
    }

    func testSingleFileUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "file_10_bytes", withExtension: nil, subdirectory: "FileResources"))
        let size = try unwrap(DownloadSize(url: url))
        expect(size.completed).to(equal(10))
        expect(size.total).to(equal(10))
    }

    func testFolderUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "folder_20_bytes", withExtension: nil, subdirectory: "FileResources"))
        let size = try unwrap(DownloadSize(url: url))
        expect(size.completed).to(equal(20))
        expect(size.total).to(equal(20))
    }

    func testNestedFolderUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "nested_folder_30_bytes", withExtension: nil, subdirectory: "FileResources"))
        let size = try unwrap(DownloadSize(url: url))
        expect(size.completed).to(equal(30))
        expect(size.total).to(equal(30))
    }

    func testNonLocalUrl() {
        expect(DownloadSize(url: Stream.onDemand.url)).to(beNil())
    }

    func testMissingFileUrl() {
        expect(DownloadSize(url: URL(filePath: "/tmp/missing"))).to(beNil())
    }
}
