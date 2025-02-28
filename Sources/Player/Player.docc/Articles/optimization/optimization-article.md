# Optimization

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: optimization-card, alt: "An image depicting a speedometer.")
}

Avoid wasting system resources unnecessarily.

## Overview

Applications must use system resources—such as CPU, memory, and network bandwidth—efficiently to avoid excessive memory consumption (which could lead to app termination) and to conserve battery life.

Media playback is frequently highlighted in product specifications as a key indicator of battery performance. This is no coincidence, as activities like video streaming involve significant resource demands: the network interface must wake periodically to download content, the processor must decode it, and the screen must remain active to display it to the user.

By ensuring your application manages resources responsibly, especially when handling video or audio playback, you enhance the user experience. Not only will users be able to enjoy your content for longer, but they’ll also extend their device’s battery life, enabling more use on a single charge.

This article discusses a few strategies to reduce resource consumption associated with ``PillarboxPlayer`` in your application.

## Profile your application

"We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. Yet we should not pass up our opportunities in that critical 3%."  
– Donald Knuth

Use Instruments to identify optimization opportunities. Focus on the following areas:

- **Allocations Instrument:** Analyze memory usage to identify excessive consumption associated with your application process. You can filter allocations, such as with the keyword _player_, to pinpoint playback-related resources and verify that their count aligns with your expectations.
- **Time Profiler Instrument:** Detect unusual CPU activity and identify potential bottlenecks in your application's performance.
- **Animation Hitches Instrument:** Investigate frame rate hiccups, particularly when players are displayed in scrollable views, to ensure smooth user interactions.
- **Activity Monitor Instrument:**
Since media playback occurs out-of-process through dedicated media services daemons (e.g., _mediaplaybackd_), use Activity Monitor to analyze their CPU and memory usage. Filter for daemons with names containing _media_ to focus on relevant processes.

To gain a comprehensive understanding of your application's memory and CPU usage, you should therefore evaluate not only its own process but also the media service daemons it interacts with.

## Restrict the number of players loaded with content

An empty ``Player`` instance is lightweight, but once loaded with content, it interacts with media service daemons to handle playback. The more player instances your application loads simultaneously, the more CPU, memory, and potentially network resources are therefore consumed.

To minimize resource usage, aim to keep the number of ``Player`` instances loaded with content as low as possible. Consider these strategies:

- **Implement a Player Pool:** Instead of creating a new player instance for every need, maintain a pool of reusable players. Borrow a player from the pool when needed and return it when done.
- **Clear Unused Players:** Use ``Player/removeAllItems()`` to empty a player's item queue without destroying the player instance. When reloading previously played content, use ``PlaybackConfiguration/position`` to resume playback from where it was last interrupted.
- **Leverage Thumbnails:** Display thumbnails representing the first frame or video content to create the illusion of instant playback without loading the actual video. This approach is especially effective in scrollable lists with autoplay functionality.
- **Limit Buffering:** Control the player's buffering behavior by setting ``PlaybackConfiguration/preferredForwardBufferDuration`` in a ``PlayerItem`` configuration. While the default buffering can be quite aggressive, reducing the buffer duration lowers memory usage but increases the likelihood of playback stalling and re-buffering. Use this setting judiciously to balance resource usage and playback stability.

## Implement autoplay wisely

Autoplay is a common feature, but its implementation requires careful consideration, as it can lead to unnecessary resource consumption. While ``PillarboxPlayer`` does not provide dedicated APIs for autoplay, if you plan to implement this functionality, consider the following best practices to enhance the user experience:

- **Make Autoplay Optional:** Always provide a setting to disable autoplay. Some users may find this feature intrusive and prefer to turn it off. Offering this option is not only user-friendly but also environmentally conscious, as it helps conserve resources.
- **Disable Autoplay in Poor Conditions:** Automatically disable autoplay when the user is connected to a mobile network or when [Low Data](https://support.apple.com/en-is/102433) or [Low Power](https://support.apple.com/en-us/101604) modes are enabled. This ensures a better experience by reducing resource consumption in constrained conditions.

## Configure players to minimize resource usage

``PillarboxPlayer`` provides settings to help reduce resource usage. Consider the following available options:

- **Disable Non-Essential Players in Low Data Mode:** Players that serve a purely decorative purpose can be automatically disabled when [Low Data Mode](https://support.apple.com/en-is/102433) is enabled. To do this, set ``PlayerConfiguration/allowsConstrainedNetworkAccess`` to `false` in the configuration provided at player creation.
- **Provide a Quality Selector:** Users may want to reduce network bandwidth usage for economical or environmental reasons. Consider offering a range of ``PlayerLimits`` that users can choose from, allowing them to select the best option for their needs.

## Optimize user interface refreshes

``PillarboxPlayer`` offers various tools to optimize view layouts in response to <doc:state-observation-article>. For detailed guidance, please refer to the <doc:optimizing-custom-layouts> tutorial.
