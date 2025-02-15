#!/bin/bash

: '
    Step 1: Update and upgrade the system.
'
echo "Updating and upgrading the system..."
{
    apt-get update -y && apt-get upgrade -y
} &> /dev/null

: '
    Step 2: Set timezone.
'
echo "Applying new timezone..."
{
    timedatectl set-timezone Europe/Amsterdam
} &> /dev/null

: '
    Step 3: Install first packages.
'
echo "Installing first packages..."
{
    apt-get install net-tools ca-certificates git nano -y
} &> /dev/null

: '
    Step 4: Install Docker.
'
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

: '
    Step 5: Disable ipv6 and reboot the system.
'
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

: '
    Step 6: Reboot the system.
'
echo "Rebooting the system..."
{
    reboot
} &> /dev/null
