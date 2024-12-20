# Asset Resource Loading

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: asset-resource-loading-card, alt: "An image depicting a dashed circle.")
}

Customize how resources associated with an asset are loaded.

## Overview

You can control how resources linked to an ``Asset`` delivered by a ``PlayerItem`` are loaded. This is achieved by implementing a custom [`AVAssetResourceLoaderDelegate`](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate), which is provided to the asset when it is created.

### Create a resource loader delegate

To customize the loading of resources, create a type that conforms to [`AVAssetResourceLoaderDelegate`](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate). Implement the necessary methods to handle resource requests and authentication challenges, as required by the resource being played.

For more detailed guidance on implementing a resource loader, refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate) and associated code samples.

### Associate a resource loader delegate with an asset

A ``PlayerItem``’s primary role is to deliver an ``Asset`` to be played. The asset not only provides the URL but can also be associated with a resource loader delegate.

To link your custom resource loader delegate to an asset:

- Ensure your ``PlayerItem`` publisher provides a custom ``Asset``, which includes the resource loader delegate.
- Alternatively, if you have all the required metadata and the URL, you can use one of the available ``PlayerItem`` custom construction helpers to create the asset and associate it with the delegate.
