#!/bin/bash

# Prüfen, ob Parameter vorhanden sind
if [ $# -eq 0 ]; then
    OPTIONAL_STEPS=0
else
    OPTIONAL_STEPS=1
fi

get_value() {
    local step=$1
    shift
    for arg in "$@"; do
        if [[ "$arg" == $step=* ]]; then
            echo "${arg#*=}"
            return 0
        elif [[ "$arg" == "$step" ]]; then
            echo ""
            return 0
        fi
    done
    return 1
}

should_run() {
    local step=$1
    shift
    if [ "$OPTIONAL_STEPS" -eq 0 ]; then
        return 1
    fi
    for arg in "$@"; do
        if [[ "$arg" == $step* ]]; then
            return 0
        fi
    done
    return 1
}

echo "Updating and upgrading the system..."
{
    echo "* system is updated!"
} &> /dev/null


if should_run "setTimeZone" "$@"; then
    echo "Applying new timezone..."
else
    echo "Applying new timezone... [SKIPPED]"
fi

echo "Installing first packages..."
{
    echo "* installed packages!"
} &> /dev/null

if should_run "installDocker" "$@"; then
    echo "Installing Docker..."
else
    echo "Installing Docker... [SKIPPED]"
fi