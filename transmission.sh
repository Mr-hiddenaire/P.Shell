#!/usr/bin/env bash

#APPLICATION_SERVICE_PATH="/opt/htdocs/P.Services"
APPLICATION_SERVICE_PATH="/data/www/P.Services"
#PHP_BIN_PATH="/usr/bin/php"
PHP_BIN_PATH="/usr/bin/php73"

TRANSMISSION_DOWNLOAD_DIR="/var/lib/transmission/Downloads"

for file in "$TRANSMISSION_DOWNLOAD_DIR"/*
do
  if [ -f "$file" ]
  then
    DOWNLOADED_FILE_NAME=$(basename "$file")
    DOWNLOADED_FILE_EXTENSION="${DOWNLOADED_FILE_NAME##*.}"
    HASH_FILE_NAME=$(echo -n "$DOWNLOADED_FILE_NAME" | md5sum | awk '{print $1}')
    DESTINATION_FILE="$TRANSMISSION_DOWNLOAD_DIR"/"$HASH_FILE_NAME"."$DOWNLOADED_FILE_EXTENSION"

    if [ "$DOWNLOADED_FILE_EXTENSION" == "mkv" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "wmv" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "avi" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "mp4" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "mpeg4" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "mpegps" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "flv" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "3gp" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "webm" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "mov" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "mpg" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "m4v" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "srt" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "ssa" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "ttml" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "sbv" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "dfxp" ] \
    || [ "$DOWNLOADED_FILE_EXTENSION" == "vtt" ]
    then
      mv "$file" "$DESTINATION_FILE"
      FILE_STRINGS_F="$FILE_STRINGS_F""$HASH_FILE_NAME"."$DOWNLOADED_FILE_EXTENSION",
      echo "file: Moving" "$file" "to" "$DESTINATION_FILE"
    fi
  elif [ -d "$file" ]
  then
    EXCLUDE_DIR_NAME=$(basename "$file")
    if [ "$EXCLUDE_DIR_NAME" == "cache" ] || [ "$EXCLUDE_DIR_NAME" == "incomplete" ] || [ "$EXCLUDE_DIR_NAME" == "hls" ]
    then
      continue
    fi
    for file_sub in "$file"/*
    do
      DOWNLOADED_DIR_NAME=$(basename "$file")
      DOWNLOADED_FILE_NAME=$(basename "$file_sub")
      DOWNLOADED_FILE_EXTENSION="${DOWNLOADED_FILE_NAME##*.}"
      HASH_FILE_NAME=$(echo -n "$DOWNLOADED_FILE_NAME""$DOWNLOADED_DIR_NAME" | md5sum |awk '{print $1}')
      DESTINATION_FILE="$TRANSMISSION_DOWNLOAD_DIR"/"$HASH_FILE_NAME"."$DOWNLOADED_FILE_EXTENSION"

      if [ "$DOWNLOADED_FILE_EXTENSION" == "mkv" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "wmv" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "avi" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "mp4" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "mpeg4" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "mpegps" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "flv" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "3gp" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "webm" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "mov" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "mpg" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "m4v" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "srt" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "ssa" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "ttml" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "sbv" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "dfxp" ] \
      || [ "$DOWNLOADED_FILE_EXTENSION" == "vtt" ]
      then
        mv "$file_sub" "$DESTINATION_FILE"
        FILE_STRINGS_D="$FILE_STRINGS_D""$HASH_FILE_NAME"."$DOWNLOADED_FILE_EXTENSION",
        echo "Directory: Moving" "$file_sub" "to" "$DESTINATION_FILE"
      fi
    done

    FILE_STRINGS_D="$FILE_STRINGS_D"
    FILE_STRINGS_D="${FILE_STRINGS_D%,*}"

    # Call application service
    if [ "$FILE_STRINGS_D" ]
    then
      cd "$APPLICATION_SERVICE_PATH" && "$PHP_BIN_PATH" artisan transmission:callback:main --files="$FILE_STRINGS_D"
      unset FILE_STRINGS_D
    fi
  fi
done

FILE_STRINGS_F=${FILE_STRINGS_F%,*}

# Call application service
if [ "$FILE_STRINGS_F" ]
then
  cd "$APPLICATION_SERVICE_PATH" && "$PHP_BIN_PATH" artisan transmission:callback:main --files="$FILE_STRINGS_F"
fi

unset FILE_STRINGS_F
unset FILE_STRINGS_D