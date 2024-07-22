#!/bin/bash

# Function to get the latest download URL for Docker
get_latest_Docker_url() {
# Replace the following line with a command or script to fetch the latest download URL
# For example, you might use curl or wget to get the download link from the Docker website
# Example: LATEST_URL=$(curl -s https://example.com/Docker-latest-url)
LATEST_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module&_gl=1*paaxuf*_ga*MjExNjg2NTgxLjE2ODY3OTQ2MjQ.*_ga_XJWPQMJYHQ*MTcwNDQ1NDA0Mi4yMS4xLjE3MDQ0NTQwNzIuMzAuMC4w"
echo "$LATEST_URL"
}
# Grab the username of the user that last logged in (current user).
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
# Function to download and install the latest version of Docker
install_Docker() {
# Get the latest download URL
Docker_URL=$(get_latest_Docker_url)

# Download the latest version
curl -L -o "/tmp/Docker-latest.dmg" "$Docker_URL"

# Mount the cached Docker .dmg
hdiutil attach /tmp/Docker-latest.dmg

# Install the application
"/Volumes/Docker/Docker.app/Contents/MacOS/install" --user="$currentUser" --accept-license

# Unmount the DMG
hdiutil detach "/Volumes/Docker"

# Install additional Docker components so users don't need admin rights
su "$currentUser" -c "/Applications/Docker.app/Contents/MacOS/Docker" --unattended &
su "$currentUser" -c "/Applications/Docker.app/Contents/MacOS/Docker" --install-privileged-components &

# Cleanup the temporary files
rm "/tmp/Docker-latest.dmg"

echo "Docker has been installed successfully!"
}

# Run the installation function
install_Docker
