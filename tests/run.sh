#!/bin/bash

set -e

DIR=$(dirname "$(readlink -f "$0")")

FAIL=0
PASS=0

for CHECK in $DIR/* ; do
    if [ ! -d "$CHECK" ] ; then
        continue
    fi
    CHECK_NAME=$(basename "$CHECK")
    echo "######## $CHECK_NAME ########"
    pushd "$CHECK" >/dev/null

    if ./run.sh ; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi

    popd >/dev/null
    echo ""
done

echo ""
if [ "$FAIL" -eq 0 ] ; then
    echo "ALL PASS!"
else
    echo "!!! FAIL !!!"
    exit 1
fi
