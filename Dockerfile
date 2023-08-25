FROM ubuntu:22.04

# Update the package list, install sudo, create a non-root user, and grant password-less sudo permissions
RUN apt update
RUN apt install -y sudo
RUN addgroup nonroot

RUN sudo apt-get update
#Instalando Curl
RUN sudo apt-get install -y curl
#Instalando wget
RUN sudo apt-get install -y wget

#Instalando devtunnel
#Comandos que no se deben olvidar correr al crear el devtunnel
#devtunnel user login -g -d
#devtunnel token TUNNELID --scope connect
RUN curl -sL https://aka.ms/DevTunnelCliInstall | bash

#Instalando VSCode
RUN sudo apt-get update && sudo apt-get install -y gnupg2
RUN sudo apt-get install -y software-properties-common
RUN sudo wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
RUN sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
RUN sudo apt update
RUN sudo apt install code -y

#Making home writteable
RUN sudo chmod -R a+rwX /home

RUN sudo sysctl -w fs.inotify.max_user_watches=524288

ADD ./entrypoint.sh /usr/bin/entrypoint.sh
RUN sudo chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["bash", "/usr/bin/entrypoint.sh"]