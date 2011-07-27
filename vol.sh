#!/bin/bash

_volstr=$(amixer sget Master,0 | grep -m 1 '[[:digit:]]*%') > /dev/null
_status=$(echo $_volstr | egrep -o -m 1 "\[on\]|\[off\]" | tr -d '[]')

if [[ $_status == 'off' ]]; then
    echo '∅'
    exit 0
fi

echo $_volstr | grep -o -m 1 '[[:digit:]]*%' | tr -d '%'
