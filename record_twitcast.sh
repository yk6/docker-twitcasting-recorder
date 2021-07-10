#!/bin/bash
# TwitCasting Live Stream Recorder

if [[ ! -n "$1" ]]; then
  echo "usage: $0 twitcasting_id [loop|once] [interval]"
  exit 1
fi

INTERVAL="${3:-10}"

while true; do
  # Monitor live streams of specific user
  while true; do
    LOG_PREFIX=$(date +"[%m/%d/%y %H:%M:%S] [twitcasting@$1] ")
    STREAM_API="https://twitcasting.tv/streamserver.php?target=$1&mode=client"
    (curl -s "$STREAM_API" | grep -q '"live":true') && break

    echo "$LOG_PREFIX The stream is not available now. Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done

  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  FNAME="twitcast_${1}_$(date +"%Y%m%d_%H%M%S").ts"
  echo "$LOG_PREFIX Start recording..."

  # Also record low resolution stream simultaneously as backup
  M3U8_URL="http://twitcasting.tv/$1/metastream.m3u8?video=1"
  ffmpeg -i "$M3U8_URL" -codec copy -f mpegts "/download/m3u8_$FNAME" &

  # Start recording
  docker run --rm --name "record_livedl" -v "${ARCHIVE}:/livedl" ghcr.io/jim60105/livedl:my-docker-build "https://twitcasting.tv/$1" -tcas -tcas-retry=on -tcas-retry-interval 30

  # Exit if we just need to record current stream
  LOG_PREFIX=$(date +"[%m/%d/%y %H:%M:%S] [twitcasting@$1] ")
  echo "$LOG_PREFIX Live stream recording stopped."
  [[ "$2" == "once" ]] && break
done
