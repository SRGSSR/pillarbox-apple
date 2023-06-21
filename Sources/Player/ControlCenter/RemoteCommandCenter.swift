//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import MediaPlayer

protocol RemoteCommandRegistrable {
    associatedtype Command: MPRemoteCommand

    var command: KeyPath<MPRemoteCommandCenter, Command> { get }
    var target: Any? { get }
}

private struct RemoteCommandRegistration<Command>: RemoteCommandRegistrable where Command: MPRemoteCommand {
    let command: KeyPath<MPRemoteCommandCenter, Command>
    let target: Any?
}

extension MPRemoteCommandCenter {
    func register(
        command: KeyPath<MPRemoteCommandCenter, some MPRemoteCommand>,
        handler: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus
    ) -> some RemoteCommandRegistrable {
        let target = self[keyPath: command].addTarget(handler: handler)
        return RemoteCommandRegistration(command: command, target: target)
    }

    func unregister(_ registration: some RemoteCommandRegistrable) {
        self[keyPath: registration.command].removeTarget(registration.target)
    }
}
