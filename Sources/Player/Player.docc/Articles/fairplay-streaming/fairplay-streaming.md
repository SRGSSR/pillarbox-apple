# FairPlay Streaming

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: fairplay-streaming-card, alt: "An image depicting a lock.")
}

Play content protected with Apple FairPlay DRM.

## Overview

You can manage [FairPlay](https://developer.apple.com/streaming/fps/) decryption keys associated with an ``Asset`` delivered by a ``PlayerItem``. This involves implementing a custom [`AVContentKeySessionDelegate`](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate) which is provided to the asset at creation time.

### Create a content key session delegate

Create a type conforming to [`AVContentKeySessionDelegate`](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate) and implement content key retrieval, as required by the resource that must be played.

Please refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/avcontentkeysessiondelegate) and code samples for more information about how a content key session delegate must be implemented.

### Associate a content key sesion delegate with an asset

The main responsibility of a ``PlayerItem`` loaded into a ``Player`` is to deliver an ``Asset`` to be actually played. Assets do not only convey the URL to be played but can also be attached a content key session delegate.

To associate an instance of the content key session delegate type you created above, have your custom ``PlayerItem`` publisher deliver an encrypted asset to which an instance of the delegate can be supplied. Alternatively, and provided you have all metadata and the URL to be played readily available, you can simply use one of the available ``PlayerItem`` encrypted construction helpers.
