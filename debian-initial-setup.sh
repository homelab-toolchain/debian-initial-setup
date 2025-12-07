#!/bin/bash

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

: '
    Step 1: Update and upgrade the system.
'
echo "Updating and upgrading the system..."
{
    apt-get update -y && apt-get upgrade -y
} &> /dev/null

: '
    (Optional) Step 2: Set timezone.
'
if should_run "setTimeZone" "$@"; then
    echo "Applying new timezone..."
    {
        timezone=$(get_value "setTimeZone" "$@")
        # Fallback: Etc/UTC
        [ -z "$timezone" ] && timezone="Etc/UTC"
        timedatectl set-timezone "$timezone"
    } &> /dev/null
else
    echo "Applying new timezone... [SKIPPED]"
fi

: '
    Step 3: Install first packages.
'
echo "Installing first packages..."
{
    apt-get install net-tools ca-certificates git nano curl -y
} &> /dev/null

: '
    (Optional) Step 4: Install Docker.
'
if should_run "installDocker" "$@"; then
    echo "Installing Docker..."
    {
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg; done
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update -y && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    } &> /dev/null
else
    echo "Installing Docker... [SKIPPED]"
fi

: '
    (Optional) Step 5: Disable ipv6 and reboot the system.
'
if should_run "disableIPv6" "$@"; then
    echo "Disabling IPv6..."
    touch /etc/sysctl.d/99-disable-ipv6.conf
    {
        {
            echo "net.ipv6.conf.all.disable_ipv6 = 1"
            echo "net.ipv6.conf.default.disable_ipv6 = 1"
            echo "net.ipv6.conf.lo.disable_ipv6 = 1"
        } >> /etc/sysctl.d/99-disable-ipv6.conf
        echo "Applying sysctl-settings..."
    } &> /dev/null
else
    echo "Disabling IPv6... [SKIPPED]"
fi

: '
    Step 6: Reboot the system.
'
echo "Rebooting the system..."
{
    reboot
} &> /dev/null
