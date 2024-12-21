# Metrics

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metrics-card, alt: "An image depicting a waveform inspected by a magnifying glass.")
}

Inspect key metrics during playback.

## Overview

Delivering the best playback experience to your users is essential but can be challenging. Media playback involves numerous components—stream encoding, packaging, metadata delivery, CDN performance, and network quality—all of which can impact the user experience.

> Tip: For more information on stream encoding and packaging, refer to <doc:stream-encoding-and-packaging-advice-article>.

To gauge how users perceive your playback experience, consider the following:

- **Startup Time:** How long does a user wait before content starts playing?
- **Error Rates:** How often do playback sessions fail, and what are the most common errors?
- **Stalls and Recovery:** How frequently does playback stall? How long do users wait for it to resume?

Pillarbox ``Player`` provides extensive metrics to help answer these questions and optimize the user experience.

## Receive metrics on demand

You can access playback metrics at any time by calling the ``Player/metrics()`` method. These metrics are also available through ``PlayerProperties``.

## Receive metrics periodically

Subscribe to ``Player/periodicMetricsPublisher(forInterval:queue:limit:)`` to receive a continuous stream of ``Metrics`` related to the current playback item.

These metrics include both instantaneous values (e.g. bandwidth estimates, content bitrate) and cumulative data since the last update. This helps you analyze not only the overall playback session but also its performance over regular intervals.

## Receive important metric-related events

Subscribe to ``Player/metricEventsPublisher`` to receive a stream of ``MetricEvent``s for the item being played.

These events include:

- Timing events (e.g. metadata and asset loading durations).
- Warnings and errors.

For detailed information on supported events, refer to the documentation on ``MetricEvent/Kind-swift.enum``.

## Visualize metrics on-device

A ``MetricsCollector`` is available to simplify the collection of ``Metrics`` and ``MetricEvent``s for the current playback item.

Since ``MetricsCollector`` is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject), you can use it to build custom visualizations using SwiftUI.

> Tip: Use [Swift Charts](https://developer.apple.com/documentation/charts) to easily visualize cumulative values (``Metrics/total``) and incremental changes (``Metrics/increment``).

## Monitor metrics remotely

Metrics collected locally can be sent to a service for remote monitoring. Trackers are especially suited to this task.

For more details, refer to <doc:tracking-article>.

> Tip: Pillarbox offers a pre-built monitoring platform and a corresponding tracker, available through the PillarboxMonitoring package.
