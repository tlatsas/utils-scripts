#!/bin/bash

# Change alsa volume levels and display notifications using libnotify
#
# author: Tasos Latsas <tlatsas2000 _at_ gmail _dot_ com>

# A more polished version of the original script found in ubuntu forums:
# http://ubuntuforums.org/showpost.php?p=7241817&postcount=2

show_help () {
cat << EOF
usage: $0 [OPTIONS] [up | down | toggle]

Increase/decrease/mute using alsa mixer and display notifications


[OPTIONS]
  -h    Show this message
  -c    Alsa mixer channel (default: Master)
  -s    Step to increase/decrease volume (default: 5)
  -d    Display notifications using libnotify (default: off)

[up|down|toggle]
Alsa mixer actions
  up     : Increase volume (amixer set 'channel' 'step'+)
  down   : Decrease volume (amixer set 'channel' 'step'-)
  toggle : Mute/Unmute volume (amixer set 'channel' toggle)

EOF
}

# default values
_display_notification=0
_step=5
_channel="Master"

# notification values
_time=1000
_text="Volume Control"


while getopts ":hdc:s:" options; do
  case ${options} in
    h)
      show_help
      exit 0
      ;;
    d)
      _display_notification=1
      ;;
    c)
      _channel=${OPTARG}
      ;;
    s)
      _step=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      exit 1
      ;;
  esac
done

# utils
_amixer=$(which amixer) || exit 1
if [[ $_display_notification -eq 1 ]]; then
    _notify=$(which notify-send) || exit 1
fi
_command="${@:$OPTIND}"

case ${_command} in
    "")
        ;;
    "up")
        ${_amixer} set ${_channel} ${_step}+ > /dev/null
        ;;
    "down")
        ${_amixer} set ${_channel} ${_step}- > /dev/null
        ;;
    "toggle")
        ${_amixer} set ${_channel} ${_command} > /dev/null
        ;;
    *)
        echo "Unknown command - use up, down, toggle"
        echo "try -h for help"
        exit 1
        ;;
esac

echo $(${_amixer} sget ${_channel} | grep -o -m 1 '[[:digit:]]*%' | tr -d '%')

[[ $_display_notification -eq 0 ]] && exit 0

# get channel status
STATUS=$(${_amixer} sget ${_channel} | awk '/[0-9]*%/ { print $NF }' | uniq )

if [ $STATUS = '[off]' ]; then
    VOLUME="Muted"
    ICON="audio-volume-muted"
else
    VOLUME=$(${_amixer} sget ${_channel} | grep -o -m 1 '[[:digit:]]*%' | tr -d '%')
    if [[ $VOLUME -eq 0 ]]; then
        ICON="audio-volume-off"
    elif [[ $VOLUME -lt 33 ]]; then
        ICON="audio-volume-low"
    elif [[ $VOLUME -lt 66 ]]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi
    VOLUME="${VOLUME}%"
fi

${_notify} "${_text}" "$VOLUME" -i $ICON -t ${_time}

exit 0
