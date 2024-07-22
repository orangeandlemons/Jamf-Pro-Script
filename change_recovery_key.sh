#Author：orales
#Date：2023/5/16

#!/bin/sh

# Change the recovery key
#sudo fdesetup changerecovery -personal

# Force device to check into Jamf
sudo jamf recon

exit 0
