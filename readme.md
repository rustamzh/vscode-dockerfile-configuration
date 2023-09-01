# Aleleba VSCode Dockerfile Configuration

This repository contains a Dockerfile configuration for use with Visual Studio Code with dev tunnel.

## Getting Started

To run the Docker container, follow these steps:

1. Clone this repository to your local machine.
2. Open the integrated terminal in Visual Studio Code.
3. Run the Docker container by running the following command: `docker run -it -e HOME_USER=custom-home-user -e VSCODE_TUNNEL_NAME=vscode-ssh-remote-server -v /path/to/extensions.json:/home/extensions.json aleleba/vscode`

### Environment Variables

The following environment variables can be set when running the Docker container:

- `HOME_USER`: The username of the user running the container. This is used to set the correct permissions on files created in the container.
- `VSCODE_TUNNEL_NAME`: The name of the SSH tunnel used by Visual Studio Code to connect to the container.

### Adding VSCode Extensions

To add VSCode extensions to the container, create a JSON file with an array of objects containing the extension details you want to install, the only Mandatory field is uniqueIdentifier and follow this structure. For example:
```
[
    {
        "extensionsGroup": {
            "description": "Extensions of Spanish Language Pack",
            "extensions": [
                {
                    "name": "Spanish Language Pack for Visual Studio Code",
                    "notes": "Extension of Spanish Language Pack for Visual Studio Code",
                    "uniqueIdentifier": "ms-ceintl.vscode-language-pack-es"
                }
            ]
        }
    },
    {
        "extensionsGroup": {
            "description": "Extensions of Github Copilot",
            "extensions": [
                {
                    "name": "GitHub Copilot",
                    "notes": "Extension of GitHub Copilot",
                    "uniqueIdentifier": "github.copilot"
                },
                {
                    "name": "GitHub Copilot Chat",
                    "notes": "Extension of GitHub Copilot Chat",
                    "uniqueIdentifier": "github.copilot-chat"
                }
            ]
        }
    }
]
```

Save this file as `extensions.json` and add it as a volume when running the Docker container on /home/extensions.json. For example:
`docker run -it -e HOME_USER=custom-home-user -e VSCODE_TUNNEL_NAME=vscode-ssh-remote-server -v /path/to/extensions.json:/home/extensions.json aleleba/vscode`


The extensions will be installed automatically after the container is created.

### Using Docker Compose

Alternatively, you can use Docker Compose to run the container with the `aleleba/vscode` image and the `HOME_USER` and `VSCODE_TUNNEL_NAME` environment variables set. Here's an example `docker-compose.yml` file:

```
version: '3'

services:
  vscode:
    image: aleleba/vscode
    environment:
      HOME_USER: custom-home-user
      VSCODE_TUNNEL_NAME: vscode-ssh-remote-server
    volumes:
      - /path/to/extensions.json:/home/extensions.json
```

You can run this `docker-compose.yml` file by navigating to the directory where it is saved and running the following command: `docker-compose up -d`

This will start the container in the background and output the container ID. You can then use the `docker ps` command to view the running container.

## Using this image as a base image in a Dockerfile

To use this image as a base image in a Dockerfile, you can add the following line to the top of your Dockerfile and you can install any additional packages you need, here an example installing nvm and nodejs in a `Dockerfile`:

```
FROM aleleba/vscode:latest

# Installing node.js and NVM
SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN nvm install --lts
RUN nvm alias default lts/*
SHELL ["/bin/sh", "-c"]
RUN echo 'source ~/.nvm/nvm.sh' >> ~/.bashrc
# Finishing installing node.js and NVM

```

## Contributing

If you'd like to contribute to this project, please fork the repository and create a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

I hope this helps! Let me know if you have any further questions.
