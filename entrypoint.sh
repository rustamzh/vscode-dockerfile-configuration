#!/bin/bash
#if [[ -z "${HOME_USER}" ]]; then
    #HOME_USER="vscode"
#fi

set -e

# use specified user name or use `vscode` if not specified
HOME_USER="${HOME_USER:-vscode}"

# use specified group name or use the same user name also as the group name
MY_GROUP="${MY_GROUP:-${HOME_USER}}"

# use the specified UID for the user
MY_UID="${MY_UID:-1000}"

# use the specified GID for the user
MY_GID="${MY_GID:-${MY_UID}}"


# check to see if group exists; if not, create it
if grep -q -E "^${MY_GROUP}:" /etc/group > /dev/null 2>&1
then
  echo "INFO: Group exists; skipping creation"
else
  echo "INFO: Group doesn't exist; creating..."
  # create the group
  sudo addgroup -g "${MY_GID}" "${MY_GROUP}" || (echo "INFO: Group exists but with a different name; renaming..."; sudo groupmod -g "${MY_GID}" -n "${MY_GROUP}" "$(awk -F ':' '{print $1":"$3}' < /etc/group | grep ":${MY_GID}$" | awk -F ":" '{print $1}')")
fi


# check to see if user exists; if not, create it
if id -u "${HOME_USER}" > /dev/null 2>&1
then
  echo "INFO: User exists; skipping creation"
else
  echo "INFO: User doesn't exist; creating..."
  # create the user
  sudo adduser -u "${MY_UID}" -G "${MY_GROUP}" -h "/home/${HOME_USER}" -s /bin/sh -D "${HOME_USER}"
fi

# addgroup nonroot
#adduser --disabled-password --gecos "" ${HOME_USER}
# echo "${HOME_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Creating extensions folder
sudo mkdir /home/${HOME_USER}/.config/Code
sudo chmod -R a+rwX /home/${HOME_USER}/.config/Code
sudo mkdir /home/${HOME_USER}/.vscode-server
sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server
sudo mkdir /home/${HOME_USER}/.vscode-server-insiders
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
