
# ``CoreBusiness``

@Metadata {
    @PageColor(yellow)
}

The CoreBusiness library provides standard SRG SSR business integration:

- Player items to load standard content delivered by the Integration Layer.
- Standard page view, hidden event and streaming analytics (comScore and TagCommander / Webtrekk).


## Background Playback

- note: For SRG SSR content, though, your application must not implement background video playback to avoid issues with comScore measurements. Please implement proper Picture in Picture support instead.
