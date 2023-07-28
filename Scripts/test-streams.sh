#!/bin/bash

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")

GENERATED_DIR="/tmp/pillarbox"
GENERATED_STREAMS_DIR="$GENERATED_DIR/streams"
METADATA_DIR="$SCRIPT_DIR/../metadata"

ON_DEMAND_DIR="$GENERATED_STREAMS_DIR/on_demand"
ON_DEMAND_TRACKS_DIR="$GENERATED_STREAMS_DIR/on_demand_tracks"
ON_DEMAND_SHORT_DIR="$GENERATED_STREAMS_DIR/on_demand_short"
ON_DEMAND_MEDIUM_DIR="$GENERATED_STREAMS_DIR/on_demand_medium"
ON_DEMAND_CROPPED_DIR="$GENERATED_STREAMS_DIR/on_demand_cropped"
ON_DEMAND_CORRUPT_DIR="$GENERATED_STREAMS_DIR/on_demand_corrupt"

LIVE_DIR="$GENERATED_STREAMS_DIR/live"
DVR_DIR="$GENERATED_STREAMS_DIR/dvr"

function serve_test_streams {
    kill_test_streams

    if ! command -v python3 &> /dev/null; then
        echo "python3 could not be found"
        exit 1
    fi

    if ! command -v ffmpeg &> /dev/null; then
        echo "ffmpeg could not be found"
        exit 1
    fi

    mkdir -p "$GENERATED_STREAMS_DIR"
    cp -R "$METADATA_DIR" "$GENERATED_STREAMS_DIR"

    # Video
    ffmpeg -f lavfi -i testsrc=duration=4:size=640x360:rate=30 -pix_fmt yuv420p -g 30 "$GENERATED_STREAMS_DIR/source_640x360.mp4" > /dev/null 2>&1
    ffmpeg -f lavfi -i testsrc=duration=4:size=360x360:rate=30 -pix_fmt yuv420p -g 30 "$GENERATED_STREAMS_DIR/source_360x360.mp4" > /dev/null 2>&1

    # Audio
    ffmpeg -f lavfi -i anullsrc=duration=4:channel_layout=stereo:sample_rate=44100 -metadata:s:a:0 language=eng $GENERATED_STREAMS_DIR/source_audio_eng.mp4
    ffmpeg -f lavfi -i anullsrc=duration=4:channel_layout=stereo:sample_rate=44100 -metadata:s:a:0 language=fre $GENERATED_STREAMS_DIR/source_audio_fre.mp4

    # Shaka
    shaka-packager \
    "in=$GENERATED_STREAMS_DIR/source_640x360.mp4,stream=video,segment_template=$ON_DEMAND_TRACKS_DIR/640x360/\$Number\$.ts" \
    "in=$GENERATED_STREAMS_DIR/source_audio_eng.mp4,stream=audio,segment_template=$ON_DEMAND_TRACKS_DIR/audio_eng/\$Number\$.ts,lang=en,hls_name=English" \
    "in=$GENERATED_STREAMS_DIR/source_audio_fre.mp4,stream=audio,segment_template=$ON_DEMAND_TRACKS_DIR/audio_fre/\$Number\$.ts,lang=fr,hls_name=Français" \
    --hls_master_playlist_output $ON_DEMAND_TRACKS_DIR/master.m3u8

    mkdir -p "$ON_DEMAND_DIR"
    ffmpeg -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -t 120 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$ON_DEMAND_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_SHORT_DIR"
    ffmpeg -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -t 1 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$ON_DEMAND_SHORT_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_MEDIUM_DIR"
    ffmpeg -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -t 5 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$ON_DEMAND_MEDIUM_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_CROPPED_DIR"
    ffmpeg -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_360x360.mp4" -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -t 120 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$ON_DEMAND_CROPPED_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$ON_DEMAND_CORRUPT_DIR"
    ffmpeg -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -t 2 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$ON_DEMAND_CORRUPT_DIR/master.m3u8" > /dev/null 2>&1 && rm "$ON_DEMAND_CORRUPT_DIR"/*.ts &

    mkdir -p "$LIVE_DIR"
    ffmpeg -stream_loop -1 -re -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -re -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 3 -hls_flags delete_segments+round_durations "$LIVE_DIR/master.m3u8" > /dev/null 2>&1 &

    mkdir -p "$DVR_DIR"
    ffmpeg -stream_loop -1 -re -i "$GENERATED_STREAMS_DIR/source_640x360.mp4" -stream_loop -1 -re -i "$GENERATED_STREAMS_DIR/source_audio_eng.mp4" -vcodec copy -acodec copy \
        -f hls -hls_time 1 -hls_list_size 20 -hls_flags delete_segments+round_durations "$DVR_DIR/master.m3u8" > /dev/null 2>&1 &

    python3 -m http.server 8123 --directory "$GENERATED_STREAMS_DIR" > /dev/null 2>&1 &
}

function kill_test_streams {
    # Kill all processes accessing the generated stream directory (wait for termination)
    while pkill -if "$GENERATED_STREAMS_DIR"; do
        sleep 1
    done

    rm -rf "$GENERATED_DIR"
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
