# Resource Loading

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: resource-loading, alt: "An image of a circle arrow in a cloud.")
}

Customize how assets are loaded.

## Overview

You can customize how an ``Asset`` delivered by a ``PlayerItem`` must be loaded. This involves implementing a custom [AVAssetResourceLoaderDelegate](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) which is provided to the asset at creation time.

Implementing a custom resource loader delegate is usually not required, especially if the content to be played is natively supported or if you are using <doc:FairPlayStreaming>.

### Create a resource loader delegate

Create a type conforming to `AVAssetResourceLoaderDelegate` and implement request and authentication challenges, as required by the resource that must be played.

Please refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) and code samples for more information about how a resource loader must be implemented.

### Associate a resource loader delegate with an asset

The main responsibility of a ``PlayerItem`` loaded into a ``Player`` is to deliver an ``Asset`` to be actually played. Assets do not only convey the URL to be played but can also be attached a resource loader delegate describing how resource retrieval actually takes place.

To associate an instance of the resource loader delegate type you created above, have your custom ``PlayerItem`` publisher deliver a custom asset to which an instance of the delegate can be supplied. Alternatively, and provided you have all metadata and the URL to be played readily available, you can simply use one of the available ``PlayerItem`` custom construction helpers.
