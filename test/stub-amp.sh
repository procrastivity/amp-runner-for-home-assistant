#!/bin/sh
echo "amp $*"
echo "cwd $(pwd)"
if [ -n "${AMP_API_KEY}" ]; then
    echo "AMP_API_KEY is set"
fi
