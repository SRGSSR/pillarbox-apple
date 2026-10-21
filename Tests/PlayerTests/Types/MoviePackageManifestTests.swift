//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxCircumspect

final class MoviePackageManifestTests: TestCase {
    func testValidParsing() throws {
        let bootXml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <HLSMoviePackage schemaLocation="http://apple.com/IMG/Schemas/HLSMoviePackage /System/Library/Schemas/HLSMoviePackage.xsd"
                xmlns="http://apple.com/IMG/Schemas/HLSMoviePackage" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <Version>1.0</Version>
              <HLSMoviePackageType>PersistedStore</HLSMoviePackageType>
              <Streams>
                <Stream ID="0-3619739-XULJM7HZFBVN2ACHDWIEYVEEPTTKCIJS" NetworkURL="https://streaming.example.com/index-f1-v1.m3u8"
                    Path="0-3619739-XULJM7HZFBVN2ACHDWIEYVEEPTTKCIJS">
                  <Complete>YES</Complete>
                </Stream>
                <Stream ID="1-3619739-FB2GR2JF7M6G7X25UB4QFPVU3REWJD25" NetworkURL="https://streaming.example.com/index-f1-a1.m3u8"
                    Path="1-3619739-FB2GR2JF7M6G7X25UB4QFPVU3REWJD25">
                  <Complete>YES</Complete>
                </Stream>
              </Streams>
              <MasterPlaylist>
                <NetworkURL>https://streaming.example.com/master.m3u8</NetworkURL>
              </MasterPlaylist>
              <DataItems Directory="Data">
                <DataItem>
                  <ID>B5EAC128-D433-4263-9E9A-DB51524FEFC7</ID>
                  <Category>Playlist</Category>
                  <Name>master.m3u8</Name>
                  <DescriptorPath>Playlist-master.m3u8-B5EAC128-D433-4263-9E9A-DB51524FEFC7.descriptor</DescriptorPath>
                  <DataPath>Playlist-B5EAC128-D433-4263-9E9A-DB51524FEFC7-master.m3u8</DataPath>
                  <Role>Master</Role>
                </DataItem>
              </DataItems>
            </HLSMoviePackage>
            """
        let bootXmlData = try unwrap(bootXml.data(using: .utf8))
        let package = try MoviePackageManifest(data: bootXmlData)
        expect(package.masterPlaylistUrl).to(equal(URL(string: "https://streaming.example.com/master.m3u8")!))
        expect(package.streams).to(equalDiff([
            .init(path: "0-3619739-XULJM7HZFBVN2ACHDWIEYVEEPTTKCIJS", networkUrl: URL(string: "https://streaming.example.com/index-f1-v1.m3u8")!),
            .init(path: "1-3619739-FB2GR2JF7M6G7X25UB4QFPVU3REWJD25", networkUrl: URL(string: "https://streaming.example.com/index-f1-a1.m3u8")!)
        ]))
    }

    func testInvalidXml() throws {
        let bootXml = ""
        let bootXmlData = try unwrap(bootXml.data(using: .utf8))
        expect(try MoviePackageManifest(data: bootXmlData)).to(throwError())
    }

    // swiftlint:disable:next inclusive_language
    func testMissingMasterPlaylist() throws {
        let bootXml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <HLSMoviePackage schemaLocation="http://apple.com/IMG/Schemas/HLSMoviePackage /System/Library/Schemas/HLSMoviePackage.xsd"
                xmlns="http://apple.com/IMG/Schemas/HLSMoviePackage" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <Version>1.0</Version>
              <HLSMoviePackageType>PersistedStore</HLSMoviePackageType>
              <Streams>
                <Stream ID="0-3619739-XULJM7HZFBVN2ACHDWIEYVEEPTTKCIJS" NetworkURL="https://streaming.example.com/index-f1-v1.m3u8"
                    Path="0-3619739-XULJM7HZFBVN2ACHDWIEYVEEPTTKCIJS">
                  <Complete>YES</Complete>
                </Stream>
                <Stream ID="1-3619739-FB2GR2JF7M6G7X25UB4QFPVU3REWJD25" NetworkURL="https://streaming.example.com/index-f1-a1.m3u8"
                    Path="1-3619739-FB2GR2JF7M6G7X25UB4QFPVU3REWJD25">
                  <Complete>YES</Complete>
                </Stream>
              </Streams>
              <DataItems Directory="Data">
                <DataItem>
                  <ID>B5EAC128-D433-4263-9E9A-DB51524FEFC7</ID>
                  <Category>Playlist</Category>
                  <Name>master.m3u8</Name>
                  <DescriptorPath>Playlist-master.m3u8-B5EAC128-D433-4263-9E9A-DB51524FEFC7.descriptor</DescriptorPath>
                  <DataPath>Playlist-B5EAC128-D433-4263-9E9A-DB51524FEFC7-master.m3u8</DataPath>
                  <Role>Master</Role>
                </DataItem>
              </DataItems>
            </HLSMoviePackage>
            """
        let bootXmlData = try unwrap(bootXml.data(using: .utf8))
        expect(try MoviePackageManifest(data: bootXmlData)).to(throwError())
    }
}
