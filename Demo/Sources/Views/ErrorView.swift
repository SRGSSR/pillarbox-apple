//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCoreBusiness
import PillarboxMonitoring
import PillarboxPlayer
import SwiftUI

struct ErrorView: View {
    let error: Error
    @ObservedObject var player: Player

    private var subtitle: String? {
        let sessionIdentifiers = player.currentSessionIdentifiers(trackedBy: MetricsTracker.self)
        guard !sessionIdentifiers.isEmpty else { return nil }
        return "Monitoring: \(sessionIdentifiers.joined(separator: ", "))"
    }

    private var imageName: String {
        switch error {
        case let error as DataError:
            switch error.kind {
            case let .blocked(reason: reason):
                return Self.imageName(for: reason)
            case .http:
                return "cloud.fill"
            case .noResourceAvailable:
                return "exclamationmark.triangle.fill"
            }
        case let error as NSError where error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue:
            return "network.slash"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            messageView()
#if os(iOS)
            retryView()
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .contentShape(.rect)
        .onTapGesture(perform: player.replay)
        .accessibilityAddTraits(.isButton)
#if os(iOS)
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
#endif
    }

    // swiftlint:disable:next cyclomatic_complexity
    private static func imageName(for reason: MediaComposition.BlockingReason) -> String {
        switch reason {
        case .ageRating12:
            return "12.circle.fill"
        case .ageRating18:
            return "18.circle.fill"
        case .commercial:
            return "megaphone.fill"
        case .endDate, .startDate:
            return "clock.fill"
        case .geoblocked:
            return "globe.europe.africa.fill"
        case .journalistic:
            return "newspaper.fill"
        case .legal:
            return "hand.raised.fill"
        case .unknown:
            return "exclamationmark.triangle.fill"
        case .vpnOrProxyDetected:
            return "key.icloud.fill"
        }
    }

    private func messageView() -> some View {
        UnavailableView {
            Label {
                Text(error.localizedDescription)
            } icon: {
                Image(systemName: imageName)
            }
        } description: {
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
#if os(iOS)
                    .textSelection(.enabled)
#endif
            }
        }
    }

    private func retryView() -> some View {
        Text("Tap to retry")
            .font(.callout)
            .padding(.bottom)
    }
}
