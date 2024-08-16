# Metrics

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metrics-card, alt: "An image depicting a waveform inspected by a looking glass.")
}

Inspect key metrics during playback.

## Overview

Providing the best playback experience to your users is crucial. This can prove to be challenging, especially since media playback involves many moving parts (stream encoding and packaging, metadata delivery, CDN, network quality), all possibly negatively impacting the end user experience in various ways.

> Tip: More information about stream encoding and packaging please refer to <doc:stream-encoding-and-packaging-advice-article>.

To better understand how your playback experience is perceived by your users, you usually need to ask yourself:

- How long does a user wait for content to be ready to play?
- How many playback sessions fail with an error, and which errors occur the most?
- Do stalls occur often and for which reasons? How much users do have to wait for playback to resume?

Pillarbox ``Player`` provides extensive metrics which can help you provide answer to these questions.

## Obtain metrics periodically

Subscribe to ``Player/periodicMetricsPublisher(forInterval:queue:limit:)`` to receive a stream of ``Metrics`` related to the item currently being played.

These metrics contain various instantaneous measurements, e.g. a bandwidth estimate or the bitrate of the content being played, but also cumulative values and increments since the last measurement. They are especially useful to understand not only what happens globally during a playback session, but also at regular time intervals.

## Receive important metric-related events

Subscribe to ``Player/metricEventsPublisher`` to receive a stream of ``MetricEvent``s related to the item currently being played.

Events include timing events (e.g. initial asset or resource loading) as well as fatal and non-fatal errors. Please refer to the documentation to learn more about all ``MetricEvent/Kind-swift.enum``s of events that are currently supported.

## Visualize metrics on-device

A ``MetricsCollector`` is provided to easily collect ``Metrics`` as well as ``MetricEvent``s for the item currently being played. Since the collector is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) it can be used to build custom visual data representations, for example using SwiftUI.

> Tip: Values from ``Metrics/increment`` and ``Metrics/total`` can be easily visualized with the help of [Swift Charts](https://developer.apple.com/documentation/charts).  

## Monitor metrics remotely

Metrics collected locally can be sent to a service for remote monitoring. Trackers are especially suited to this task. See <doc:tracking-article> for more information.

> Tip: Pillarbox offers a ready-to-use monitoring platform and a corresponding tracker available from the PillarboxMonitoring package.
