//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import MediaPlayer
import PillarboxCore

public struct PlayerMetadata {
    struct _Data {
        static let empty = Self(items: [], timedGroups: [], chapterGroups: [])

        let items: [MetadataItem]
        let timedGroups: [TimedMetadataGroup]
        let chapterGroups: [TimedMetadataGroup]
    }

    // TODO: We could revisit the cases to have common names but different labels (e.g. chapter(time:) and chapter(index:))
    //       once supported, see https://github.com/apple/swift/issues/52479
    public enum Kind {
        case global
        case timed(CMTime)
        case chapterAt(CMTime)
        case chapter(Int)
    }

    static let empty = Self(content: .empty, resource: .empty)

    let content: _Data
    let resource: _Data

    public var numberOfChapters: Int {
        chapterGroups.count
    }

    var items: [MetadataItem] {
        !content.items.isEmpty ? content.items : resource.items
    }

    var timedGroups: [TimedMetadataGroup] {
        !content.timedGroups.isEmpty ? content.timedGroups : resource.timedGroups
    }

    var chapterGroups: [TimedMetadataGroup] {
        !content.chapterGroups.isEmpty ? content.chapterGroups : resource.chapterGroups
    }

    var nowPlayingInfo: NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()

        nowPlayingInfo[MPMediaItemPropertyTitle] = stringValue(for: .commonIdentifierTitle, kind: .global)
        nowPlayingInfo[MPMediaItemPropertyArtist] = stringValue(for: .iTunesMetadataTrackSubTitle, kind: .global)

        if let imageData = dataValue(for: .commonIdentifierArtwork, kind: .global), let image = UIImage(data: imageData) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        return nowPlayingInfo
    }

    private static func item(for identifier: AVMetadataIdentifier, in groups: [TimedMetadataGroup], at time: CMTime) -> MetadataItem? {
        guard let group = groups.first(where: { $0.containsTime(time) }) else { return nil }
        return item(for: identifier, in: group)
    }

    private static func item(for identifier: AVMetadataIdentifier, in group: TimedMetadataGroup) -> MetadataItem? {
        group.items.first { $0.identifier == identifier }
    }
}

public extension PlayerMetadata {
    func value(for identifier: AVMetadataIdentifier, kind: Kind) -> Any? {
        item(for: identifier, kind: kind)?.value
    }

    func stringValue(for identifier: AVMetadataIdentifier, kind: Kind) -> String? {
        item(for: identifier, kind: kind)?.stringValue
    }

    func integerValue(for identifier: AVMetadataIdentifier, kind: Kind) -> Int? {
        item(for: identifier, kind: kind)?.integerValue
    }

    func doubleValue(for identifier: AVMetadataIdentifier, kind: Kind) -> Double? {
        item(for: identifier, kind: kind)?.doubleValue
    }

    func dateValue(for identifier: AVMetadataIdentifier, kind: Kind) -> Date? {
        item(for: identifier, kind: kind)?.dateValue
    }

    func dataValue(for identifier: AVMetadataIdentifier, kind: Kind) -> Data? {
        item(for: identifier, kind: kind)?.dataValue
    }

    private func item(for identifier: AVMetadataIdentifier, kind: Kind) -> MetadataItem? {
        switch kind {
        case .global:
            return items.first { $0.identifier == identifier }
        case let .timed(time):
            return Self.item(for: identifier, in: timedGroups, at: time)
        case let .chapterAt(time: time):
            return Self.item(for: identifier, in: chapterGroups, at: time)
        case let .chapter(index):
            guard let group = chapterGroups[safeIndex: index] else { return nil }
            return Self.item(for: identifier, in: group)
        }
    }
}
