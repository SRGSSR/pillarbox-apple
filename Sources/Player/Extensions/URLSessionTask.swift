//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

private var kLocationSubjectKey: Void?
private var kErrorSubjectKey: Void?

extension URLSessionTask {
    var locationPublisher: AnyPublisher<URL?, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    private var locationSubject: CurrentValueSubject<URL?, Never> {
        if let subject = objc_getAssociatedObject(self, &kLocationSubjectKey) as? CurrentValueSubject<URL?, Never> {
            return subject
        }
        else {
            let subject = CurrentValueSubject<URL?, Never>(nil)
            objc_setAssociatedObject(self, &kLocationSubjectKey, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return subject
        }
    }

    private var errorSubject: CurrentValueSubject<Error?, Never> {
        if let subject = objc_getAssociatedObject(self, &kErrorSubjectKey) as? CurrentValueSubject<Error?, Never> {
            return subject
        }
        else {
            let subject = CurrentValueSubject<Error?, Never>(nil)
            objc_setAssociatedObject(self, &kErrorSubjectKey, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return subject
        }
    }

    func attachLocation(_ location: URL) {
        locationSubject.send(location)
    }

    func attachError(_ error: Error) {
        errorSubject.send(error)
    }
}
