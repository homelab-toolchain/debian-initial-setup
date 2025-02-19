# General

1. Update and upgrade the system
2. (Optional) Set timezone. Fallback if no value is given: `Etc/UTC`
3. Install first packages (i.e. curl, net-tools, ca-certificates, git, nano)
4. (Optional) Install Docker 
5. (Optional) Disable IPv6
6. Reboot the system

# Prerequsites

1. Internet connection.
2. Log in as root.
3. Install `curl` or just call the following command:
```
apt-get update -y && apt-get install curl -y
```

# How to Execute

If you want to execute all non-optional steps described above, you can run the following command without any input parameter:
```
curl -sSL https://github.com/homelab-toolchain/debian-initial-setup/raw/refs/heads/main/debian-initial-setup.sh | bash
```

If you want to execute optional steps too, you can use the input arguments. <br>
The following example activates all optional steps (simply remove those that are not required):
```
curl -sSL https://github.com/homelab-toolchain/debian-initial-setup/raw/refs/heads/main/debian-initial-setup.sh | bash -s setTimeZone=Europe/Amsterdam installDocker disableIPv6
```

# Test

The specified script was tested on `Debian 12.9`. It should theoretically run on any version.