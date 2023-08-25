#!/bin/bash
[[ -z "${HOME_USER}" ]] && (adduser --disabled-password --gecos "" vscode && echo 'vscode ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && sudo su - vscode) \
    || (adduser --disabled-password --gecos "" ${HOME_USER} && echo '${HOME_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && sudo su - ${HOME_USER})
[[ -z "${VSCODE_TUNNEL_NAME}" ]] && code tunnel --accept-server-license-terms || code tunnel --accept-server-license-terms --name ${VSCODE_TUNNEL_NAME}