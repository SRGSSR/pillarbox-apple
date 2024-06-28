//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricLogUpdate {
    private let log: MetricLog?
    private let event: MetricLogEvent

    init(log: MetricLog?, event: MetricLogEvent) {
        self.log = log
        self.event = event
    }

    func save() async {
        await log?.addEvent(event)
    }
}
