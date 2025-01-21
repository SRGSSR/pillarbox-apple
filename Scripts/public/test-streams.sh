#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

GENERATED_DIR="/tmp/pillarbox"

METADATA_DIR="$SCRIPT_DIR/../../metadata"
SUBTITLES_DIR="$METADATA_DIR/subtitles"
JSON_DIR="$METADATA_DIR/json"

function serve_test_streams {
    local dest_dir="$1"

    kill_test_streams "$dest_dir"

    mkdir -p "$dest_dir"
    cp -R "$JSON_DIR" "$dest_dir"

    local sources_dir="$dest_dir/sources"
    generate_sources "$sources_dir"
    generate_simple_streams "$sources_dir" "$dest_dir/simple"
    generate_packaged_streams "$sources_dir" "$dest_dir/packaged"
    serve_directory "$dest_dir"
}

function generate_sources {
    local dest_dir="$1"
    mkdir -p "$dest_dir"

    # Video
    ffmpeg -f lavfi -i testsrc=duration=4:size=640x360:rate=30 -pix_fmt yuv420p -g 30 "$dest_dir/source_640x360.mp4" > /dev/null 2>&1
    ffmpeg -f lavfi -i testsrc=duration=4:size=360x360:rate=30 -pix_fmt yuv420p -g 30 "$dest_dir/source_360x360.mp4" > /dev/null 2>&1

    # Audio
    ffmpeg -f lavfi -i anullsrc=duration=4:channel_layout=stereo:sample_rate=44100 -metadata:s:a:0 language=eng "$dest_dir/source_audio_eng.mp4" > /dev/null 2>&1
    ffmpeg -f lavfi -i anullsrc=duration=4:channel_layout=stereo:sample_rate=44100 -metadata:s:a:0 language=fre "$dest_dir/source_audio_fre.mp4" > /dev/null 2>&1
}

function generate_simple_streams {
    local src_dir="$1"
    local dest_dir="$2"

    local on_demand_dir="$dest_dir/on_demand"
    mkdir -p "$on_demand_dir"
    ffmpeg -stream_loop -1 -i "$src_dir/source_640x360.mp4" -stream_loop -1 -i "$src_dir/source_audio_eng.mp4" -t 120 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$on_demand_dir/master.m3u8" > /dev/null 2>&1 &

    local on_demand_short_dir="$dest_dir/on_demand_short"
    mkdir -p "$on_demand_short_dir"
    ffmpeg -stream_loop -1 -i "$src_dir/source_640x360.mp4" -stream_loop -1 -i "$src_dir/source_audio_eng.mp4" -t 1 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$on_demand_short_dir/master.m3u8" > /dev/null 2>&1 &

    local on_demand_medium_dir="$dest_dir/on_demand_medium"
    mkdir -p "$on_demand_medium_dir"
    ffmpeg -stream_loop -1 -i "$src_dir/source_640x360.mp4" -stream_loop -1 -i "$src_dir/source_audio_eng.mp4" -t 5 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$on_demand_medium_dir/master.m3u8" > /dev/null 2>&1 &

    local on_demand_square_dir="$dest_dir/on_demand_square"
    mkdir -p "$on_demand_square_dir"
    ffmpeg -stream_loop -1 -i "$src_dir/source_360x360.mp4" -stream_loop -1 -i "$src_dir/source_audio_eng.mp4" -t 120 -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 0 -hls_flags round_durations "$on_demand_square_dir/master.m3u8" > /dev/null 2>&1 &

    local live_dir="$dest_dir/live"
    mkdir -p "$live_dir"
    ffmpeg -stream_loop -1 -re -i "$src_dir/source_640x360.mp4" -stream_loop -1 -re -i "$src_dir/source_audio_eng.mp4" -vcodec copy -acodec copy \
        -f hls -hls_time 4 -hls_list_size 3 -hls_flags delete_segments+round_durations "$live_dir/master.m3u8" > /dev/null 2>&1 &

    local dvr_dir="$dest_dir/dvr"
    mkdir -p "$dvr_dir"
    ffmpeg -stream_loop -1 -re -i "$src_dir/source_640x360.mp4" -stream_loop -1 -re -i "$src_dir/source_audio_eng.mp4" -vcodec copy -acodec copy \
        -f hls -hls_time 1 -hls_list_size 20 -hls_flags delete_segments+round_durations "$dvr_dir/master.m3u8" > /dev/null 2>&1 &
}

function generate_packaged_streams {
    local src_dir="$1"
    local dest_dir="$2"

    mkdir -p "$dest_dir"

    local on_demand_with_options_dir="$dest_dir/on_demand_with_options"
    packager \
        "in=$src_dir/source_640x360.mp4,stream=video,segment_template=$on_demand_with_options_dir/640x360/\$Number\$.ts" \
        "in=$src_dir/source_audio_eng.mp4,stream=audio,segment_template=$on_demand_with_options_dir/audio_eng/\$Number\$.ts,lang=en,hls_name=English" \
        "in=$src_dir/source_audio_fre.mp4,stream=audio,segment_template=$on_demand_with_options_dir/audio_fre/\$Number\$.ts,lang=fr,hls_name=Français" \
        "in=$src_dir/source_audio_eng.mp4,stream=audio,segment_template=$on_demand_with_options_dir/audio_eng_ad/\$Number\$.ts,lang=en,hls_name=English (AD),hls_characteristics=public.accessibility.describes-video" \
        "in=$SUBTITLES_DIR/subtitles_en.webvtt,stream=text,segment_template=$on_demand_with_options_dir/subtitles_en/\$Number\$.vtt,lang=en,hls_name=English" \
        "in=$SUBTITLES_DIR/subtitles_fr.webvtt,stream=text,segment_template=$on_demand_with_options_dir/subtitles_fr/\$Number\$.vtt,lang=fr,hls_name=Français" \
        "in=$SUBTITLES_DIR/subtitles_ja.webvtt,stream=text,segment_template=$on_demand_with_options_dir/subtitles_ja/\$Number\$.vtt,lang=ja,hls_name=日本語" \
        --hls_master_playlist_output "$on_demand_with_options_dir/master.m3u8" > /dev/null 2>&1

    local on_demand_without_options_dir="$dest_dir/on_demand_without_options"
    packager \
        "in=$src_dir/source_640x360.mp4,stream=video,segment_template=$on_demand_without_options_dir/640x360/\$Number\$.ts" \
        --hls_master_playlist_output "$on_demand_without_options_dir/master.m3u8" > /dev/null 2>&1

    local on_demand_with_single_audible_option_dir="$dest_dir/on_demand_with_single_audible_option"
    packager \
        "in=$src_dir/source_640x360.mp4,stream=video,segment_template=$on_demand_with_single_audible_option_dir/640x360/\$Number\$.ts" \
        "in=$src_dir/source_audio_eng.mp4,stream=audio,segment_template=$on_demand_with_single_audible_option_dir/audio_eng/\$Number\$.ts,lang=en,hls_name=English" \
        --hls_master_playlist_output "$on_demand_with_single_audible_option_dir/master.m3u8" > /dev/null 2>&1
}

function serve_directory {
    python -m http.server 8123 --directory "$1" > /dev/null 2>&1 &
}

function kill_test_streams {
    local dir="$1"

    # Kill all processes accessing the generated stream directory (wait for termination)
    while pkill -if "$dir"; do
        sleep 1
    done

    rm -rf "$dir"
}

function usage {
    echo
    echo "Usage: $0 [OPTION]"
    echo "   -s         start serving test streams."
    echo "   -k         kill the server."
    echo
    exit 1
}

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    eval "$(pkgx +python +ffmpeg +packager)"
}

if [[ -z "$1" ]]; then
    usage
fi

while getopts sk OPT; do
    case "$OPT" in
        s)
            echo "Starting test streams"
            install_tools
            serve_test_streams "$GENERATED_DIR"
            echo "... done."
            ;;
        k)
            echo "Stopping test streams"
            install_tools
            kill_test_streams "$GENERATED_DIR"
            echo "... done."
            ;;
        *)
            usage
            ;;
    esac
done