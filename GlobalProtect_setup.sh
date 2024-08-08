#!/bin/bash
## Description: Checks for global preferences file and populates  
## it with the default portal if needed.
## Body ###########################################################
## Declare Variables ##############################################
  
# Global Prefs File
gPrefs=/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist
 
## Logic ##########################################################
 
# Check to see if the global preference file already exists...
if [[ -e $gPrefs ]]; then
	echo "Default global portal already exists. Skipping."
else
	echo "Setting default global portal to: vpn.carizon.com"
     # If it does not already exist, create it and populate the default portal using the echo command
       echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Palo Alto Networks</key>
    <dict>
        <key>GlobalProtect</key>
        <dict> 
            <key>PanSetup</key>
            <dict>
                <key>Portal</key>
                <string>xxx.xxx.com</string>
                <key>Prelogon</key>
                <string>0</string>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
' > $gPrefs
echo $?
	# Kill the Preference caching daemon to prevent it from overwriting any changes
	killall cfprefsd
	echo $?
fi
# Check exit code.
exit $?
