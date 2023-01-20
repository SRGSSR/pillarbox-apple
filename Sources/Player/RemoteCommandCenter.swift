//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import MediaPlayer

struct RemoteCommandRegistration {
    fileprivate let command: KeyPath<MPRemoteCommandCenter, MPRemoteCommand>
    fileprivate let target: Any?
}

extension MPRemoteCommandCenter {
    func register(
        command: KeyPath<MPRemoteCommandCenter, MPRemoteCommand>,
        handler: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus
    ) -> RemoteCommandRegistration {
        let target = self[keyPath: command].addTarget(handler: handler)
        return .init(command: command, target: target)
    }

    func unregister(_ registration: RemoteCommandRegistration?) {
        guard let registration else { return }
        self[keyPath: registration.command].removeTarget(registration.target)
    }
}
