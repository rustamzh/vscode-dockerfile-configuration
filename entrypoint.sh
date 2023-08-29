#!/bin/bash
if [[ -z "${HOME_USER}" ]]; then
    HOME_USER="vscode"
fi

addgroup nonroot
adduser --disabled-password --gecos "" ${HOME_USER}
echo "${HOME_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Creating extensions folder
sudo mkdir /home/${HOME_USER}/.vscode-server
sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server
code --extensions-dir /home/${HOME_USER}/.vscode-server

# Check if the data.json file exists
if [ -f "/home/extensions.json" ]; then
    # Read the JSON file into a variable
    jsonExtensions=$(cat /home/extensions.json)

    # Use jq to extract the array elements
    extensions=$(echo $jsonExtensions | jq -r '.[]')

    # Loop through the extensions and process each element
    for extension in $extensions; do
        echo "Installing extension: $extension"
        sudo su - ${HOME_USER} -c "code --install-extension $extension"
    done
    #sudo mkdir /home/${HOME_USER}/.vscode-server
    #sudo mkdir /home/${HOME_USER}/.vscode-server-insiders
    #sudo cp -R /home/${HOME_USER}/.vscode/* /home/${HOME_USER}/.vscode-server
    #sudo cp -R /home/${HOME_USER}/.vscode/* /home/${HOME_USER}.vscode-server-insiders
    #sudo chmod -R a+rwX /home/${HOME_USER}/.vscode
    #sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server
    #sudo chmod -R a+rwX /home/${HOME_USER}/.vscode-server-insiders
else
    echo "File extensions.json not found"
fi

if [[ -z "${VSCODE_TUNNEL_NAME}" ]]; then
    sudo su - ${HOME_USER} -c "code tunnel --accept-server-license-terms"
else
    sudo su - ${HOME_USER} -c "code tunnel --accept-server-license-terms --name ${VSCODE_TUNNEL_NAME}"
fi
