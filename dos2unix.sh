#!/bin/bash

_sed=$(which sed) || exit 1
_f="${1}"

$_sed 's/$//g' "${_f}"
