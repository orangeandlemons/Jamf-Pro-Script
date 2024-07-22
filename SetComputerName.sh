#Author：orales
#Date：2024/4/11

#!/bin/bash

# Get the currently logged-in username
LOGGED_IN_USER=$(stat -f %Su /dev/console)

sudo jamf setComputerName -name "$LOGGED_IN_USER"

exit 0
