# Test streams

Tests streams are served locally using [Python HTTP server](https://docs.python.org/3/library/http.server.html) and [ffmpeg](https://ffmpeg.org) for playlist generation.

## Local stream folder

Streams are served from the `Streams` folder when running `Scripts/test-streams-start.sh`.

## Test stream generation

Test streams are generated using ffmpeg to address various use cases.

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
