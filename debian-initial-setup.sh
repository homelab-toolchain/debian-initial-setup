#!/bin/bash

# Function to check if a specific step argument is provided and optionally extract a value
get_value() {
    local step=$1
    for arg in "$@"; do
        if [[ "$arg" == $step=* ]]; then
            echo "${arg#*=}"  # Extract value after '='
            return 0
        elif [[ "$arg" == "$step" ]]; then
            echo ""  # No value provided
            return 0
        fi
    done
    return 1
}

# Function to check if a step exists
should_run() {
    local step=$1
    if [ $# -eq 0 ]; then
        return 1  # no parameter -> no execution required
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
        [ -z "$timezone" ] && timezone="Europe/Amsterdam"
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
    apt-get install net-tools ca-certificates git nano -y
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
    {
        {
            echo "net.ipv6.conf.all.disable_ipv6 = 1"
            echo "net.ipv6.conf.default.disable_ipv6 = 1"
            echo "net.ipv6.conf.lo.disable_ipv6 = 1"
        } >> /etc/sysctl.conf
        echo "Applying sysctl-settings..."
        sysctl -p
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