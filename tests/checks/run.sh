#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

export DEBFULLNAME="#DEBFULLNAME#"
export DEBEMAIL="#DEBEMAIL#"

PASS=0
FAIL=0

for CHECK in $DIR/* ; do
    if [ ! -d "$CHECK" ] ; then
        continue
    fi
    CHECK_NAME=$(basename "$CHECK")
    echo "###### $CHECK_NAME ######"
    for TEST in $CHECK/* ; do
        if [ ! -d "$TEST" ] ; then
            continue
        fi
        pushd "$TEST" >/dev/null
        echo -n $(basename "$TEST")": "
        rm -rf test.in test.out
        cp -r in test.in
        if [ -d "out" ] ; then
            cp -r out test.out
        else
            cp -r in test.out
        fi

        pushd test.in >/dev/null
        if [ -x ../prep ] ; then
            ../prep
        fi
        MESSAGE=$(../../../../../checks/$CHECK_NAME)
        STATUS=$?
        popd >/dev/null

        EXP_MESSAGE=$(cat message 2>/dev/null)
        DIFF=$(diff -Naur --exclude=.git test.in test.out)

        if [ "$STATUS" -ne 0 ] ; then
            if [ -e "fail" ] ; then
                PASS=$(($PASS + 1))
                echo "OK"
            else
                FAIL=$(($FAIL + 1))
                echo "Exit status $STATUS"
            fi
        elif [ "$DIFF" != "" ] ; then
            FAIL=$(($FAIL + 1))
            echo "Diff"
            echo "#############################"
            echo "$DIFF"
            echo "#############################"
        elif [ "$EXP_MESSAGE" != "" ] && [ "$EXP_MESSAGE" != "$MESSAGE" ] ; then
            FAIL=$(($FAIL + 1))
            echo "Wrong message"
            echo "Expected: $EXP_MESSAGE"
            echo "Got:      $MESSAGE"
        else
            PASS=$(($PASS + 1))
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
