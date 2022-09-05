# Test streams

Tests streams are served locally using [Python HTTP server](https://docs.python.org/3/library/http.server.html) and [ffmpeg](https://ffmpeg.org) for playlist generation.

## Local stream folder

Streams are served from the `Streams` folder when running `Scripts/test-streams-start.sh`.

## Test stream generation

Test streams are generated from local files [using ffmpeg](https://ffmpeg.org/ffmpeg-formats.html) to address various use cases.

### Local media files

Local media files used for stream generation should have [fixed closed GOPs](https://marcinchmiel.com/articles/2020-10/why-you-should-force-fixed-closed-gops-and-how-to-do-it-in-ffmpeg/#making-it-work-with-ffmpeg) so that HLS streams generated from them have segment durations `hls_time` equal to a [multiple](https://superuser.com/a/1600616) of the GOP size.

Test streams should also be silent for convenience but stripping audio using ffmpeg `-na` flag does not work with unit tests. For some reason `AVPlayer` namely fails to move time forward with silent streams played in unit test suites, though such streams play fine in the simulator or on device. As a workaround we can reduce the volume of the audio to zero without stripping it, though.

With these constraints in mind we can use ffmpeg to prepare a local media file with fixed GOP size and a volume reduced to zero. Our current 4-second video source is created from the [Nyan Cat](https://www.youtube.com/watch?v=QH2-TGUlwu4) video, downloaded using [yt-dlp](https://github.com/yt-dlp/yt-dlp) and cut into a nicely looping silent 4-second clip out with a GOP size of 2:

```shell
yt-dlp --format=mp4 -o nyan_cat_original.mp4 https://www.youtube.com/watch\?v\=QH2-TGUlwu4
ffmpeg -i nyan_cat_original.mp4 -ss 10 -t 4 -force_key_frames "expr:if(isnan(prev_forced_n),1,eq(n,prev_forced_n+2))" -filter:a "volume=0" nyan_cat.mp4
```

### On-demand stream

```shell
ffmpeg -stream_loop -1 -i source.[mp4|mov] -t 120 -vcodec copy -acodec copy -f hls -hls_time 4 -hls_list_size 0 master.m3u8
```

### Livestream without DVR

```shell
ffmpeg -stream_loop -1 -re -i source.[mp4|mov|...] -vcodec copy -acodec copy -f hls -hls_time 4 -hls_list_size 3 -hls_flags delete_segments master.m3u8
```

### Livestream with DVR sliding window

```shell
ffmpeg -stream_loop -1 -re -i source.[mp4|mov|...] -vcodec copy -acodec copy -f hls -hls_time 4 -hls_list_size 20 -hls_flags delete_segments master.m3u8
```

### Livestream with DVR growing window

```shell
ffmpeg -stream_loop -1 -re -i source.[mp4|mov|...] -vcodec copy -acodec copy -f hls -hls_time 4 -hls_playlist_type event master.m3u8
```
