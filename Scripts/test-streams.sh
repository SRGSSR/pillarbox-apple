#!/bin/bash

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")

MEDIAS_DIR="$SCRIPT_DIR/../Medias"
GENERATED_STREAMS_DIR="/tmp/Pillarbox/Streams"

ON_DEMAND_DIR="$GENERATED_STREAMS_DIR/on_demand"
ON_DEMAND_SHORT_DIR="$GENERATED_STREAMS_DIR/on_demand_short"
ON_DEMAND_CORRUPT_DIR="$GENERATED_STREAMS_DIR/on_demand_corrupt"

LIVE_DIR="$GENERATED_STREAMS_DIR/live"
DVR_DIR="$GENERATED_STREAMS_DIR/dvr"

function serve_test_streams {
    kill_test_streams

    mkdir -p "$ON_DEMAND_DIR"
    ffmpeg -stream_loop -1 -i "$MEDIAS_DIR/nyan_cat.mov" -t 120 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 "$ON_DEMAND_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_SHORT_DIR"
    ffmpeg -stream_loop -1 -i "$MEDIAS_DIR/nyan_cat.mov" -t 1 -vcodec copy -acodec copy \
        -f hls -hls_time 1 -hls_list_size 0 "$ON_DEMAND_SHORT_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_CORRUPT_DIR"
    ffmpeg -stream_loop -1 -i "$MEDIAS_DIR/nyan_cat.mov" -t 2 -vcodec copy -acodec copy \
        -f hls -hls_time 1 -hls_list_size 0 "$ON_DEMAND_CORRUPT_DIR/master.m3u8" > /dev/null 2>&1; rm "$ON_DEMAND_CORRUPT_DIR"/*.ts &

    mkdir -p "$LIVE_DIR"
    ffmpeg -stream_loop -1 -re -i "$MEDIAS_DIR/nyan_cat.mov" -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 3 -hls_flags delete_segments "$LIVE_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$DVR_DIR"
    ffmpeg -stream_loop -1 -re -i "$MEDIAS_DIR/nyan_cat.mov" -vcodec copy -acodec copy \
        -f hls -hls_time 2 -hls_list_size 10 -hls_flags delete_segments "$DVR_DIR/master.m3u8" > /dev/null 2>&1 &

    python3 -m http.server --directory "$GENERATED_STREAMS_DIR" > /dev/null 2>&1 &
}

function kill_test_streams {
    pkill -if "ffmpeg -stream_loop .*/Streams/Generated/.*"
    pkill -if "python -m http.server --directory .*/Streams/Generated$"
    rm -rf "$GENERATED_STREAMS_DIR"
}

function usage {
    echo "Generate test streams and manage an HTTP server to serve them locally."
    echo ""
    echo "Usage: $SCRIPT_NAME [-s] [-k]"
    echo ""
    echo "Options:"
    echo "   -s: Start serving test streams."
    echo "   -k: Kill the server."
}

while getopts sk OPT; do
    case "$OPT" in
        s)
            serve_test_streams
            ;;
        k)
            kill_test_streams
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
