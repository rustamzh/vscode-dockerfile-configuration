#!/bin/bash
set -eu

if [[ -z "${HOME_USER-}" ]]; then
    HOME_USER="vscode"
fi

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

    sudo cp -R /home/vscode/. /home/${HOME_USER}/

    # Check if .bashrc file exists
    if [ ! -f "/home/${HOME_USER}/.bashrc" ]; then
        # If not, create it
        sudo touch /home/${HOME_USER}/.bashrc
    fi

    # Change the owner of the .bashrc file to HOME_USER
    sudo chown ${HOME_USER} /home/${HOME_USER}/.bashrc

    # Copy environment variables from vscode user to HOME_USER
    env | grep -v 'HOME_USER' | while read -r line; do
      sudo su - ${HOME_USER} -c "echo 'export $line' >> ~/.bashrc"
    done
    
    # Changing the property of the directory /home/${HOME_USER}
    sudo chown -R ${HOME_USER}: /home/${HOME_USER}/
    
    # Changing the HOME_USER in the .bashrc file
    sudo su - ${HOME_USER} -c 'sed -i "s|/home/vscode|/home/${HOME_USER}|g" ~/.bashrc'

    # Switch to the user specified by $HOME_USER and start an interactive shell session.
    # sudo -u $HOME_USER -i
    sudo su -l ${HOME_USER}
  fi
fi

# Add LS_COLORS variable to .bashrc
LS_COLORS_VALUE="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"
sudo su - ${HOME_USER} -c "echo 'export LS_COLORS=\"$LS_COLORS_VALUE\"' >> ~/.bashrc"

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
