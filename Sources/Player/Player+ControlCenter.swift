//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import MediaPlayer

public extension Player {
    /// Make the player the current active one.
    func becomeActiveIfPossible() {
        nowPlayingSession.becomeActiveIfPossible()
    }
}

extension Player {
    func updateControlCenter(nowPlayingInfo: NowPlaying.Info) {
        if !nowPlayingInfo.isEmpty {
            if nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo == nil {
                uninstallRemoteCommands()
                installRemoteCommands()
            }
            nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
        else {
            uninstallRemoteCommands()
            nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo = nil
        }
    }

    func uninstallRemoteCommands() {
        commandRegistrations.forEach { registration in
            nowPlayingSession.remoteCommandCenter.unregister(registration)
        }
        commandRegistrations = []
    }

    func nowPlayingInfoMetadataPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        currentPublisher()
            .map { current in
                guard let current else {
                    return Just(NowPlaying.Info()).eraseToAnyPublisher()
                }
                return current.item.$asset
                    .map { $0.nowPlayingInfo() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates { lhs, rhs in
                // swiftlint:disable:next legacy_objc_type
                NSDictionary(dictionary: lhs).isEqual(to: rhs)
            }
            .eraseToAnyPublisher()
    }
}

private extension Player {
    func installRemoteCommands() {
        commandRegistrations = [
            playRegistration(),
            pauseRegistration(),
            togglePlayPauseRegistration(),
            previousTrackRegistration(),
            nextTrackRegistration(),
            changePlaybackPositionRegistration(),
            skipBackwardRegistration(),
            skipForwardRegistration()
        ]
    }

    func playRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.playCommand) { [weak self] _ in
            self?.play()
            return .success
        }
    }

    func pauseRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.pauseCommand) { [weak self] _ in
            self?.pause()
            return .success
        }
    }

    func togglePlayPauseRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.togglePlayPauseCommand) { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }

    func previousTrackRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = false
        return nowPlayingSession.remoteCommandCenter.register(command: \.previousTrackCommand) { [weak self] _ in
            self?.returnToPrevious()
            return .success
        }
    }

    func nextTrackRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = false
        return nowPlayingSession.remoteCommandCenter.register(command: \.nextTrackCommand) { [weak self] _ in
            self?.advanceToNext()
            return .success
        }
    }

    func changePlaybackPositionRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.changePlaybackPositionCommand) { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(near(.init(seconds: positionEvent.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
            return .success
        }
    }

    func skipBackwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = false
        nowPlayingSession.remoteCommandCenter.skipBackwardCommand.preferredIntervals = [.init(value: configuration.backwardSkipInterval)]
        return nowPlayingSession.remoteCommandCenter.register(command: \.skipBackwardCommand) { [weak self] _ in
            self?.skipBackward()
            return .success
        }
    }

    func skipForwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = false
        nowPlayingSession.remoteCommandCenter.skipForwardCommand.preferredIntervals = [.init(value: configuration.forwardSkipInterval)]
        return nowPlayingSession.remoteCommandCenter.register(command: \.skipForwardCommand) { [weak self] _ in
            self?.skipForward()
            return .success
        }
    }
}
