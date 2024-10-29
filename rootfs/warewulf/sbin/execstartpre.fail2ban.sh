#!/bin/bash

# Author: griznog
# Purpose: Control fail2ban startup and configuration.

# Pull in warewulf functions/variables for this node.
[[ -f /warewulf/etc/functions ]] && source /warewulf/etc/functions || exit 1

# Script starts here

# Default to allow.
retval=0

# Do not allow execution from chroot.
if [[ $ww_chrooted == "true" ]]; then
    warn "$0: Starting from chroot not allowed."
    retval=1
else
    # Get flag from WW
    start='{{ if .Tags.service_fail2ban_enabled }}'

    # Do not allow execution from a container runtime. 
    warn "$0: Attempting start on platform: ${ww_platform}."
    case ${ww_platform} in 
        systemd-nspawn|lxc-libvirt|lxc|openvz|docker|rkt|container-other)
            warn "$0: Starting from a container is not allowed."
            retval=1
            ;;
        *)
            case ${start} in
                false|no|off|disable*)
                    warn "$0: Blocking fail2ban to start on ${ME}."
	                systemctl disable fail2ban
                    retval=1
                    ;;
                true|yes|on|enable*)
                    warn "$0: Allowing fail2ban to start on ${ME}."
                    retval=0
                    ;;
                *)
                    warn "$0: Error: Incorrect fail2ban_start setting: ${start}, defaulting to allow."
                    retval=0
                    ;;
             esac
            ;;
    esac
fi

exit ${retval}

