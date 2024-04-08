//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import XCTest

final class ExtractorTests: XCTestCase {
    func testExtraction() {
        let item1 = AVMetadataItem(for: .commonIdentifierTitle, value: "Title", extendedLanguageTag: "und")!
        let values = collectOutput(
            from: AVMetadataItem.extract(
                items: [item1],
                filteredByIdentifiers: [.commonIdentifierTitle],
                bestMatchingPreferredLanguages: ["und"]
            ),
            during: .milliseconds(100)
        )
        print("--> \(values)")
    }

    func testMatchingLanguageUnd() {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "title_und", extendedLanguageTag: "und")!
        expect(AVMetadataItem.metadataItems(from: [item], filteredAndSortedAccordingToPreferredLanguages: ["und"])).to(equalDiff([item]))
    }

    func testMatchingLanguageFr() {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "title_fr", extendedLanguageTag: "fr")!
        expect(AVMetadataItem.metadataItems(from: [item], filteredAndSortedAccordingToPreferredLanguages: ["fr"])).to(equalDiff([item]))
    }

    func testNonMatchingLanguageFrVsUnd() {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "title_fr", extendedLanguageTag: "fr")!
        expect(AVMetadataItem.metadataItems(from: [item], filteredAndSortedAccordingToPreferredLanguages: ["und"])).to(beEmpty())
    }

    func testNonMatchingLanguageUndVsFr() {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "title_und", extendedLanguageTag: "und")!
        expect(AVMetadataItem.metadataItems(from: [item], filteredAndSortedAccordingToPreferredLanguages: ["fr"])).to(beEmpty())
    }

    func testSeveralMatchingLanguages() {
        let item1 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_fr", extendedLanguageTag: "fr")!
        let item2 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_de", extendedLanguageTag: "de")!
        let item3 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_und", extendedLanguageTag: "und")!
        expect(AVMetadataItem.metadataItems(from: [item1, item2, item3], filteredAndSortedAccordingToPreferredLanguages: ["fr", "de"])).to(equal([item1, item2]))
    }

    func testLanguageOrderingChangesItemOrdering() {
        let item1 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_fr", extendedLanguageTag: "fr")!
        let item2 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_de", extendedLanguageTag: "de")!
        let item3 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_und", extendedLanguageTag: "und")!
        expect(AVMetadataItem.metadataItems(from: [item1, item2, item3], filteredAndSortedAccordingToPreferredLanguages: ["de", "fr"])).to(equal([item2, item1]))
    }

    func testSeveralMatchingLanguagesWithSeveralIdentifiers() {
        let item1 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_fr", extendedLanguageTag: "fr")!
        let item2 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_de", extendedLanguageTag: "de")!
        let item3 = AVMetadataItem(for: .commonIdentifierTitle, value: "title_und", extendedLanguageTag: "und")!

        let item4 = AVMetadataItem(for: .commonIdentifierArtist, value: "artist_de", extendedLanguageTag: "de")!
        let item5 = AVMetadataItem(for: .commonIdentifierArtist, value: "artist_und", extendedLanguageTag: "und")!
        expect(AVMetadataItem.metadataItems(from: [item1, item2, item3, item4, item5], filteredAndSortedAccordingToPreferredLanguages: ["fr", "de"])).to(equal([item1, item2, item4]))
    }
}
