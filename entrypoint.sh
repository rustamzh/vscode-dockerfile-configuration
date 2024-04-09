#!/bin/bash
set -eu

if [[ -z "${HOME_USER}" ]]; then
    HOME_USER="vscode"
fi

#addgroup nonroot
#adduser --disabled-password --gecos "" ${HOME_USER}
#echo "${HOME_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# We do this first to ensure sudo works below when renaming the user.
# Otherwise the current container UID may not exist in the passwd database.
eval "$(fixuid -q)"

if [ "${HOME_USER-}" ]; then
  USER="$HOME_USER"
  if [ "$HOME_USER" != "$(whoami)" ]; then
    if ! id -u $HOME_USER > /dev/null 2>&1; then
      sudo adduser --disabled-password --gecos "" ${HOME_USER}
      sudo echo "$HOME_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null
    fi

    # Copy environment variables from vscode user to HOME_USER
    env | grep -v 'HOME_USER' | while read -r line; do
      sudo su - ${HOME_USER} -c "echo 'export $line' >> ~/.bashrc"
    done

    sudo -u $HOME_USER -i
    # Unfortunately we cannot change $HOME as we cannot move any bind mounts
    # nor can we bind mount $HOME into a new home as that requires a privileged container.
    # sudo usermod --login "$HOME_USER" vscode
    # sudo groupmod -n "$HOME_USER" vscode

    # sudo sed -i "/vscode/d" /etc/sudoers.d/nopasswd
    # sudo cd /home/${HOME_USER}
    sudo chown -R ${HOME_USER}:${HOME_USER} /home/${HOME_USER}
  fi
fi


#Creating extensions folder
if [ ! -d "/home/${HOME_USER}/.config/Code" ]; then
  sudo mkdir -p /home/${HOME_USER}/.config/Code
fi
sudo chmod -R a+rwX /home/${HOME_USER}/.config/Code

if [ ! -d "/home/${HOME_USER}/.vscode-server" ]; then
  sudo mkdir -p /home/${HOME_USER}/.vscode-server
fi
sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server

if [ ! -d "/home/${HOME_USER}/.vscode-server-insiders" ]; then
  sudo mkdir -p /home/${HOME_USER}/.vscode-server-insiders
fi
sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server-insiders

# Check if the data.json file exists
if [ -f "/home/extensions.json" ]; then
    # Read the JSON file into a variable
    jsonExtensions=$(cat /home/extensions.json)

    # Use jq to extract the extension parameter from the JSON array
    extensions=$(echo $jsonExtensions | jq -r '.[].extensionsGroup.extensions[].uniqueIdentifier')

    # Loop through the extensions and process each element
    for extension in $extensions; do
        echo "Installing extension: $extension"
        sudo su - ${HOME_USER} -c "code --install-extension $extension"
    done
    sudo cp -R /home/${HOME_USER}/.vscode/* /home/${HOME_USER}/.vscode-server
    sudo cp -R /home/${HOME_USER}/.vscode/* /home/${HOME_USER}/.vscode-server-insiders
    sudo chmod -R a+rwX /home/${HOME_USER}/.vscode
    sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server
    sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server-insiders
else
    echo "File extensions.json not found"
fi

if [[ -z "${VSCODE_TUNNEL_NAME}" ]]; then
    sudo su - ${HOME_USER} -c "code tunnel --accept-server-license-terms"
else
    sudo su - ${HOME_USER} -c "code tunnel --accept-server-license-terms --name ${VSCODE_TUNNEL_NAME}"
fi
