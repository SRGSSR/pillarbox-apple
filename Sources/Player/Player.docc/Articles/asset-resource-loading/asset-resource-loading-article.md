# Asset Resource Loading

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: asset-resource-loading-card, alt: "An image depicting a dashed circle.")
}

Customize how resources associated with an asset are loaded.

## Overview

You can customize how resources associated with an ``Asset`` delivered by a ``PlayerItem`` must be loaded. This involves implementing a custom [`AVAssetResourceLoaderDelegate`](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) which is provided to the asset at creation time.

### Create a resource loader delegate

Create a type conforming to [`AVAssetResourceLoaderDelegate`](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) and implement request and authentication challenges, as required by the resource that must be played.

Please refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) and code samples for more information about how a resource loader must be implemented.

### Associate a resource loader delegate with an asset

The main responsibility of a ``PlayerItem`` loaded into a ``Player`` is to deliver an ``Asset`` to be actually played. Assets do not only convey the URL to be played but can also be attached a resource loader delegate.

To associate an instance of the resource loader delegate type you created above, have your custom ``PlayerItem`` publisher deliver a custom asset to which an instance of the delegate can be supplied. Alternatively, and provided you have all metadata and the URL to be played readily available, you can simply use one of the available ``PlayerItem`` custom construction helpers.
