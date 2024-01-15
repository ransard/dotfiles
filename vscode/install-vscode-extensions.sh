#!/bin/bash

pkglist=(
astro-build.astro-vscode
bierner.markdown-mermaid
bpruitt-goddard.mermaid-markdown-syntax-highlighting
dbaeumer.vscode-eslint
esbenp.prettier-vscode
GitHub.copilot
GitHub.copilot-chat
ms-azuretools.vscode-azureappservice
ms-azuretools.vscode-azureresourcegroups
ms-vscode-remote.remote-wsl
ms-vscode.azure-account
Prisma.prisma
svelte.svelte-vscode
vscodevim.vim
redhat.vscode-yaml
)

for i in ${pkglist[@]}; do
	code --install-extension $i
done
