# FairPlay Streaming

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: fairplay-streaming-card, alt: "An image depicting a lock.")
}

Enable playback of content protected with Apple FairPlay DRM.

## Overview

You can manage [FairPlay](https://developer.apple.com/streaming/fps/) decryption keys for an ``Asset`` delivered by a ``PlayerItem``. This process involves implementing a custom [`AVContentKeySessionDelegate`](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate), which you assign to the asset at creation.

### Create a content key session delegate

To support FairPlay decryption you need a content key session delegate:

1. **Define a Delegate Type:** Create a type conforming to [`AVContentKeySessionDelegate`](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate).
2. **Implement Key Retrieval:** Implement methods required for retrieving and managing content keys, based on the needs of the protected resource.

For detailed guidance, refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate) and related code samples.

### Associate a content key session delegate with an asset

A ``PlayerItem`` is responsible for delivering an ``Asset`` to a ``Player`` for playback. In addition to the media URL, the asset can be linked to a content key session delegate.

Several options are available to associate a content key session delegate with an item:

- Use a custom ``PlayerItem`` publisher to deliver an encrypted asset, providing the delegate instance.
- If metadata and the media URL are readily available, use one of the ``PlayerItem`` encrypted construction helpers to attach the delegate during asset creation.
