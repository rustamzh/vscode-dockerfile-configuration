#!/bin/bash
if [[ -z "${HOME_USER}" ]]; then
    HOME_USER="vscode"
fi

addgroup nonroot
adduser --disabled-password --gecos "" ${HOME_USER}
echo "${HOME_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# sudo su - ${HOME_USER}

if [[ -z "${VSCODE_TUNNEL_NAME}" ]]; then
    code tunnel --accept-server-license-terms
else
    code tunnel --accept-server-license-terms --name ${VSCODE_TUNNEL_NAME}
fi
