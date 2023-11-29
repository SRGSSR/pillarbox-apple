# Control Center

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: control-center, alt: "An image depicting the Control Center icon.")
}

Enable playback steering from the Control Center.

## Overview

> Important: Control Center integration is only meaningful for iOS apps.

``Player`` natively integrates with the iOS Control Center. Though most of this integration happens automatically your app is still responsible of activating the player instance which must be controlled by the Control Center. It must also provide the metadata (title, artwork image) associated with the ``PlayerItem`` currently being played.

### Provide player item metadata

The main responsibility of a ``PlayerItem`` loaded into a ``Player`` is to deliver an ``Asset`` to be actually played. Assets do not only convey the URL to be played but can also be attached arbitrary metadata whose only requirement is to conform to the ``AssetMetadata`` protocol.

To associate Control Center metadata with a player item:

1. Create a type which represents your asset metadata and have it conform to ``AssetMetadata``.
2. Implement the ``AssetMetadata/nowPlayingMetadata()`` method and return the ``NowPlayingMetadata`` which must be displayed in the Control Center when the item is currently being played.
3. Implement a custom ``PlayerItem`` with a metadata publisher retrieving all metadata required before delivering an asset. Alternatively, and provided you have all metadata and the URL to be played readily available, you can simply use one of the available ``PlayerItem`` construction helpers, supplying the asset metadata to be used at creation time.

### Make a player instance active

Several ``Player`` instances can coexist in an app but only one at most is able to integrate with the Control Center.

When you want one player instance to take precedence call ``Player/becomeActive()``. Any other instance which might be active will resign in the process.

You can manually call ``Player/resignActive()`` to have a player resign. If not the player instance will automatically resign when deinitialized.
