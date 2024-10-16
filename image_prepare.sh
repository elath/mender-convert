#!/bin/bash

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below.
TEMP=$(getopt   --long nocache,infile:,token: \
                -n 'image_prepare' -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around '$TEMP': they are essential!
eval set -- "$TEMP"


NOCACHE=false
INFILE=
TOKEN=
while true; do
  case "$1" in
    --nocache ) NOCACHE=true; shift ;;
    --infile ) INFILE="$2"; shift 2 ;;
    --token ) TOKEN="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo $NOCACHE
echo $INFILE
echo $TOKEN
