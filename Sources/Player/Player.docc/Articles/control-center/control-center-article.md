# Control Center

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: control-center-card, alt: "An image depicting the Control Center icon.")
}

Enable playback steering from the Control Center.

## Overview

> Note: For an example of use have a look at the <doc:integrating-with-control-center> tutorial.

``Player`` natively integrates with the Control Center. Most of this integration happens automatically but your app is still responsible of activating the player instance which must be associated with the Control Center. It must also provide the metadata (title, artwork image) associated with the ``PlayerItem`` currently being played.

> Important: The system uses some heuristics to determine whether an app is eligible for Control Center integration. In particular the [audio session](https://developer.apple.com/documentation/avfaudio/avaudiosession) must be configured with a non-mixable category option. More information is available from the [_Explore media metadata publishing and playback interactions_ WWDC session](https://developer.apple.com/videos/play/wwdc2022/110338/).

### Provide player item metadata

The main responsibility of a ``PlayerItem`` loaded into a ``Player`` is to deliver an ``Asset`` to be actually played. Assets do not only convey the URL to be played but can also be attached arbitrary metadata whose only requirement is to conform to the ``AssetMetadata`` protocol.

To associate Control Center metadata with a player item:

1. Create a type which represents your asset metadata and have it conform to ``AssetMetadata``. More information is available from the <doc:metadata-article> article.
2. Implement the ``AssetMetadata/playerMetadata`` method and return the ``PlayerMetadata`` which must be displayed in the Control Center when the item is currently being played.
3. Implement a custom ``PlayerItem`` with a metadata publisher retrieving all metadata required before delivering an asset. Alternatively, and provided you have all metadata and the URL to be played readily available, you can simply use one of the available ``PlayerItem`` construction helpers, supplying the asset metadata at creation time.

> Tip: Metadata associated with a ``PlayerItem`` is automatically published by a ``Player``. You can retrieve this metadata from the ``Player/metadata`` property and use it when building a custom user interface. The metadata is also automatically displayed by ``SystemVideoView`` in a standard way.

### Make a player instance active

Several ``Player`` instances can coexist in an app but at most one can be integrated with the Control Center at any time.

When you want one player instance to take precedence call ``Player/becomeActive()``. Any other instance which might be active will resign in the process.

You can manually call ``Player/resignActive()`` to have a player resign. Note that a player instance will automatically resign when deinitialized.

### Extend support to tvOS

Control Center integration on tvOS is achieved using a  ``SystemVideoView`` covering the whole screen. Making a player instance active is still required since this ensures that iOS devices used as remotes can also display current item information in their own Control Center.

> Note: The tvOS Control Center only displays information about audio content.
