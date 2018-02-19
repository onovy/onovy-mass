#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

PASS=0
FAIL=0

for CHECK in $DIR/* ; do
    if [ ! -d "$CHECK" ] ; then
        continue
    fi
    CHECK_NAME=$(basename "$CHECK")
    echo "###### $CHECK_NAME ######"
    pushd "$CHECK" >/dev/null
    for TEST in $CHECK/* ; do
        if [ ! -d "$TEST" ] ; then
            continue
        fi
        echo -n $(basename "$TEST")": "
        rm -rf test
        cp -r "$TEST" test
        pushd test >/dev/null
        ../../../../commit "#MESSAGE#" --test
        STATUS=$?
        DIFF=$(diff -Naur --exclude=.git test "$TEST")
        popd >/dev/null

        if [ "$STATUS" -ne 0 ] ; then
            FAIL=$(($FAIL + 1))
            echo "Exit status $STATUS"
        elif [ "$CHECK" == "dch" ] && [ "$DIFF" == "" ] ; then
            FAIL=$(($FAIL + 1))
            echo "FAIL"
        elif [ "$CHECK" == "no-dch" ] && [ "$DIFF" != "" ] ; then
            FAIL=$(($FAIL + 1))
            echo "FAIL"
        else
            PASS=$(($PASS + 1))
            echo "OK"
        fi

        rm -rf test
    done
    popd >/dev/null
done

echo ""
echo "Pass: $PASS"
if [ "$FAIL" -ne 0 ] ; then
    echo "FAIL: $FAIL"
    exit 1
fi
