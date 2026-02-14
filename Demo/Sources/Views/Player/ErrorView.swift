//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCoreBusiness
import PillarboxMonitoring
import PillarboxPlayer
import PillarboxStandardConnector
import SwiftUI

private struct ErrorLabel: View {
    let message: String
    let systemImage: String

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}

struct ErrorView: View {
    let error: Error
    @ObservedObject var player: Player

    private var subtitle: String? {
        let sessionIdentifiers = player.currentSessionIdentifiers(trackedBy: MetricsTracker.self)
        guard !sessionIdentifiers.isEmpty else { return nil }
        return "Monitoring: \(sessionIdentifiers.joined(separator: ", "))"
    }

    var body: some View {
        messageView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.white)
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
            label()
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

    @ViewBuilder
    private func label() -> some View {
        switch error {
        case let error as NSError where error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue:
            ErrorLabel(message: error.localizedDescription, systemImage: "network.slash")
        case let error as HttpError:
            ErrorLabel(message: error.localizedDescription, systemImage: "cloud.fill")
        case let error as SourceError:
            ErrorLabel(message: error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
        case let error as BlockingError:
            label(for: error)
        default:
            ErrorLabel(message: error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
        }
    }

    @ViewBuilder
    private func label(for error: BlockingError) -> some View {
        switch error.reason {
        case let .startDate(date) where date != nil:
            CountdownView(endDate: date!, metadata: player.metadata)
                .onEnded(player.replay)
        default:
            ErrorLabel(message: error.localizedDescription, systemImage: Self.imageName(for: error.reason))
        }
    }
}

#Preview {
    ErrorView(error: NSError(domain: "Unknown", code: 42), player: Player())
        .preferredColorScheme(.dark)
}
