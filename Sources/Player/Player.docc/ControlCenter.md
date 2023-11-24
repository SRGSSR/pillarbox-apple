# ControlCenter

@Metadata {
    @PageColor(purple)
}

The player supports AirPlay and can be integrated with the Control Center.

## Overview

- For AirPlay support please ensure that your application audio session and background capabilities are configured appropriately.
- Call `becomeActive()` on a player instance to enable AirPlay and Control Center support for it.
- Call `resignActive()` on a player to disable AirPlay and Control Center support for it (if currently active).

You need to call `becomeActive()` when transitioning to an immersive player experience for which these integrations make sense. Calling `resignActive()` is most of the time superfluous, except when the same player instance is reused between an immersive playback user interface and a limited playback experience.
