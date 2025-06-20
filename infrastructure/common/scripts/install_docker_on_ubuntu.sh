#!/usr/bin/env bash
set -euo pipefail

wait_for_apt_lock() {
  # Wait for apt lock to be released before proceeding
  # Set a timeout of 5 minutes (300 seconds)
  MAX_WAIT_SECONDS=300
  SECONDS_WAITED=0

  echo "Checking for apt lock..."

  # Wait for any existing apt/dpkg locks to be released
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    if [ "$SECONDS_WAITED" -ge "$MAX_WAIT_SECONDS" ]; then
      echo "Error: Timed out after 5 minutes waiting for apt lock to be released."
      echo "Another process (like unattended-upgrades or cloud-init) might be stuck."
      echo "Please check the system logs on the instance for more details."
      exit 1
    fi

    sleep 5
    SECONDS_WAITED=$((SECONDS_WAITED + 5))
    echo "Waiting for other software managers to finish... (Waited $SECONDS_WAITED seconds)"
  done

  return 0;
}

wait_for_apt_lock
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

wait_for_apt_lock
sudo apt-get update

wait_for_apt_lock
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

wait_for_apt_lock
sudo apt-get update

wait_for_apt_lock
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin
