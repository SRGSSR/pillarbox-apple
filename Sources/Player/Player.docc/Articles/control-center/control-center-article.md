# Control Center

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: control-center-card, alt: "An image depicting the Control Center icon.")
}

Enable playback steering from the Control Center.

## Overview

> Note: For a practical example, refer to the <doc:integrating-with-control-center> tutorial.

A ``Player`` instance integrates seamlessly with the Control Center, with much of the integration handled automatically. However, your app is responsible for activating the player instance linked to the Control Center and providing metadata (e.g., title, artwork) for the ``PlayerItem`` currently playing.

> Important: System heuristics determine app eligibility for Control Center integration. For example, the [audio session](https://developer.apple.com/documentation/avfaudio/avaudiosession) must use a non-mixable category option. See the [_Explore media metadata publishing and playback interactions_ WWDC session](https://developer.apple.com/videos/play/wwdc2022/110338/) for more details.

### Provide player item metadata

The primary role of a ``PlayerItem`` is to load an ``Asset`` for playback. In addition to URLs, assets can include arbitrary metadata conforming to the ``AssetMetadata`` protocol.

Follow these steps to associate metadata with a ``PlayerItem`` for Control Center integration:

1. **Define Metadata:** Create a type representing your asset metadata, ensuring it conforms to the ``AssetMetadata`` protocol. Refer to the <doc:metadata-article> article for details.
2. **Return Metadata:** Implement the ``AssetMetadata/playerMetadata`` method to return ``PlayerMetadata`` for display in the Control Center when the item is playing.
3. **Publish Metadata:** Create a custom ``PlayerItem`` that retrieves and publishes all required metadata before delivering the asset. Alternatively, if you have all metadata and the URL ready, use a ``PlayerItem`` helper method to provide metadata at creation.

Tip: The metadata you provide is also displayed in the ``SystemVideoView`` by default. When implementing a custom UI, ensure you use the same metadata to maintain consistency across the Control Center and player UI.

### Activate a player instance

While multiple ``Player`` instances can exist in your app, only one can integrate with the Control Center at a time.

- Use ``Player/becomeActive()`` to prioritize a player instance, automatically resigning any active instance.
- Call ``Player/resignActive()`` to manually deactivate a player instance. Instances also resign automatically when deinitialized.

### Support tvOS

On tvOS, Control Center integration requires using a full-screen ``SystemVideoView``. Activating a player instance ensures compatibility with iOS devices acting as remotes, allowing them to display current item information in their own Control Center.

> Note: On tvOS, the Control Center only displays audio content information.
