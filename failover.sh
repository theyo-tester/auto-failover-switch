#!/bin/bash
#script that will check internet connectivity and, if needed, will switch to the "backup" or back to "main" ISP if main is available meanwhile.

# ======= CONFIG CONSTANTS ======= 
# Define main and backup gateways
MAIN_STATIC_IP="x.y.z.10"
MAIN_GATEWAY="x.y.z.9"  # Replace with the IP address of your main gateway

BACKUP_STATIC_IP="u.v.w.102"
BACKUP_GATEWAY="u.v.w.1"  # Replace with the IP address of your backup gateway

# Define a reliable external server to ping
PING_TARGET="1.1.1.1"  # Google's DNS server

# Define the interface associated with the main and backup gateways
MAIN_INTERFACE="enp13s0"  # Replace eth0 with the interface associated with your main gateway
BACKUP_INTERFACE="enp15s0"  # Replace eth1 with the interface associated with your backup gateway
DOMAIN_TO_UPDATE="some.domain.tld"

# ToDo: define a man->backup & backup->main hook (external script, or command) to be executed, after doing the switchover

# Ping the target server to check internet connectivity
#ping -c 2 -W 1 $PING_TARGET > /dev/null

# ======= FUNCTIONS ======= 
# Function to switch to main internet connection
switch_to_main() {
    # echo "Switching back to main internet connection."
    # Add routing rule to switch to main gateway
    ip route replace default via $MAIN_GATEWAY dev $MAIN_INTERFACE
    # ToDo. add generic hook
    # v-change-web-domain-ip dan $DOMAIN_TO_UPDATE  $MAIN_STATIC_IP yes
    # Flush existing rules ToDo. add generic hook
    #  v-update-firewall
#   echo "Switched to main internet connection."
}

# Function to switch to backup internet connection
switch_to_backup() {
    #echo "Switching to backup internet connection."
    # Add routing rule to switch to backup gateway
    ip route replace default via $BACKUP_GATEWAY dev $BACKUP_INTERFACE
    # ToDo. add generic hook
    #v-change-web-domain-ip dan $DOMAIN_TO_UPDATE $BACKUP_STATIC_IP yes
    # Flush existing rules, ToDo. add generic hook
    # v-update-firewall
    #echo "Switched to backup internet connection."
}

is_on_main() {
# Check which interface the default route is pointing to
DEFAULT_ROUTE=$(ip route | grep -m 1 default | awk '{print $5}')
if [ "$DEFAULT_ROUTE" = "$MAIN_INTERFACE" ]; then
    #echo "Connection is over the main interface ($MAIN_INTERFACE)."
    return 0
elif [ "$DEFAULT_ROUTE" = "$BACKUP_INTERFACE" ]; then
    #echo "Connection is over the backup interface ($BACKUP_INTERFACE)."
    return 1
else
    echo "Connection is over an unknown interface: $DEFAULT_ROUTE."
    return 2
fi
}


is_reachable_over_if() {
# Ping the target server using the specified interface
ping -c 1 -W 2 -I $1 $PING_TARGET > /dev/null

if [ $? -eq 0 ]; then
#    echo "Internet is reachable over $1"
    return 0
else
#    echo "Internet is not reachable over $1"
    return 1
fi
}

# ======= MAIN CODE ======= 
if is_reachable_over_if $MAIN_INTERFACE; then
        if is_on_main; then
                echo "Good, the main interface is UP and running."
                exit 0; #good to exit
        else
                echo "SWITCHING TO MAIN!"
                switch_to_main
        fi
else
#       echo  "internet over the main interface s NOT reachable..."
        if is_on_main; then
                echo "SWITCHING to BACKUP!"
                switch_to_backup
        else
#               echo "already on backup, waiting until main is good to go"
                exit 0;
        fi
fi
