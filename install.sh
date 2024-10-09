#!/usr/bin/env bash

PROMPT_TIMEOUT=15 # When user is prompted for input, skip after x seconds

# Color Variables
CYAN_B='\033[1;96m'
YELLOW_B='\033[1;93m'
RED_B='\033[1;31m'
GREEN_B='\033[1;32m'
PLAIN_B='\033[1;37m'
RESET='\033[0m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'

# Checks if a given package is installed
command_exists () {
  hash "$1" 2> /dev/null
}

function apply_preferences () {
	  # If ZSH not the default shell, ask user if they'd like to set it
  if [[ $SHELL != *"zsh"* ]] && command_exists zsh; then
    echo -e "\n${CYAN_B}Would you like to set ZSH as your default shell? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans_zsh
    if [[ $ans_zsh =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
      echo -e "${PURPLE}Setting ZSH as default shell${RESET}"
      chsh -s $(which zsh) $USER
    fi
  fi
	}

# Install / update Tmux plugins with TPM
echo -e "${PURPLE}Installing TMUX Plugins${RESET}"
chmod ug+x "${XDG_DATA_HOME}/tmux/tpm"
sh "${TMUX_PLUGIN_MANAGER_PATH}/tpm/bin/install_plugins"
sh "${XDG_DATA_HOME}/tmux/plugins/tpm/bin/install_plugins"
# apply_preferences
