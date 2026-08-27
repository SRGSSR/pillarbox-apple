# ``PillarboxPlayer/PlayerItem``

## Topics

### Creating a Player Item with an Asset Loader

- ``init(assetLoaderType:input:trackerAdapters:)``

### Creating a Player Item with Asset Metadata

- ``init(asset:metadata:trackerAdapters:)-(_,AssetMetadata<CustomData>,_)``
- ``simple(url:metadata:trackerAdapters:configuration:)-(_,AssetMetadata<CustomData>,_,_)``
- ``custom(url:delegate:metadata:trackerAdapters:configuration:)-(_,_,AssetMetadata<CustomData>,_,_)``
- ``encrypted(url:delegate:metadata:trackerAdapters:configuration:)-(_,_,AssetMetadata<CustomData>,_,_)``

### Creating a Player Item with Player Metadata

- ``init(asset:metadata:trackerAdapters:)-(_,PlayerMetadata,_)``
- ``simple(url:metadata:trackerAdapters:configuration:)-(_,PlayerMetadata,_,_)``
- ``custom(url:delegate:metadata:trackerAdapters:configuration:)-(_,_,PlayerMetadata,_,_)``
- ``encrypted(url:delegate:metadata:trackerAdapters:configuration:)-(_,_,PlayerMetadata,_,_)``
