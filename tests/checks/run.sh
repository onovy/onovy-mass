#!/bin/bash

set -e

DIR=$(dirname "$(readlink -f "$0")")

export DEBFULLNAME="#DEBFULLNAME#"
export DEBEMAIL="#DEBEMAIL#"

PASS=0
FAIL=0
CHECK_ONLY=$1

for CHECK in $DIR/* ; do
    if [ ! -d "$CHECK" ] ; then
        continue
    fi
    CHECK_NAME=$(basename "$CHECK")
    if [ "$CHECK_ONLY" ] && [ "$CHECK_ONLY" != "$CHECK_NAME" ] ; then
        continue
    fi
    echo "###### $CHECK_NAME ######"
    for TEST in $CHECK/* ; do
        if [ ! -d "$TEST" ] ; then
            continue
        fi
        pushd "$TEST" >/dev/null
        echo -n "$(basename "$TEST"): "
        rm -rf test.in test.out
        cp -r in test.in

        # Pre hook IN
        pushd test.in >/dev/null
        if [ -x ../pre.in ] ; then
            ../pre.in
        fi

        if [ -d "../out" ] ; then
            cp -r ../out ../test.out
        else
            cp -r . ../test.out
        fi

        # Pre hook OUT
        pushd ../test.out >/dev/null
        if [ -x ../pre.out ] ; then
            ../pre.out
        fi
        popd >/dev/null

        set +e
        MESSAGE="$("../../../../../checks/$CHECK_NAME")"
        STATUS=$?
        set -e
        popd >/dev/null

        EXP_MESSAGE=$(cat message 2>/dev/null || true)
        DIFF=$(diff -Naur --exclude=.git test.in test.out || true)

        if [ "$STATUS" -ne 0 ] ; then
            if [ -e "fail" ] ; then
                PASS=$((PASS + 1))
                echo "OK"
            else
                FAIL=$((FAIL + 1))
                echo "Exit status $STATUS"
            fi
        elif [ "$DIFF" != "" ] ; then
            FAIL=$((FAIL + 1))
            echo "Diff"
            echo "#############################"
            echo "$DIFF"
            echo "#############################"
        elif [ "$EXP_MESSAGE" != "" ] && [ "$EXP_MESSAGE" != "$MESSAGE" ] ; then
            FAIL=$((FAIL + 1))
            echo "Wrong message"
            echo "Expected: $EXP_MESSAGE"
            echo "Got:      $MESSAGE"
        else
            PASS=$((PASS + 1))
            echo "OK"
        fi

        rm -rf test.in test.out
        popd >/dev/null
    done
done

echo ""
echo "Pass: $PASS"
if [ "$FAIL" -ne 0 ] ; then
    echo "FAIL: $FAIL"
    exit 1
fi
