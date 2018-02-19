#!/bin/bash

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
    ./run.sh
    STATUS=$?

    if [ "$STATUS" -ne 0 ] ; then
        FAIL=$(($FAIL + 1))
    else
        PASS=$(($PASS + 1))
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
