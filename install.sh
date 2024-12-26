#!/usr/bin/env bash

# Dotfiles Source Repo and Destination Directory
REPO_NAME="${REPO_NAME:-ransard/dotfiles}"
echo -e "${DOTFILES_DIR}"
DOTFILES_DIR="${DOTFILES_DIR:-${SRC_DIR:-$HOME/.dotfiles}}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${REPO_NAME}.git}"

# Config Names and Locations
TITLE="🧰 ${REPO_NAME} Setup"
SYMLINK_FILE="${SYMLINK_FILE:-install.conf.yaml}"
DOTBOT_DIR="submodules/dotbot"
DOTBOT_BIN="bin/dotbot"

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

# On error, displays death banner, and terminates app with exit code 1
terminate () {
  make_banner "Installation failed. Terminating..." ${RED_B}
  exit 1
}

make_banner () {
  bannerText=$1
  lineColor="${2:-$CYAN_B}"
  padding="${3:-0}"
  titleLen=$(expr ${#bannerText} + 2 + $padding);
  lineChar="─"; line=""
  for (( i = 0; i < "$titleLen"; ++i )); do line="${line}${lineChar}"; done
  banner="${lineColor}╭${line}╮\n│ ${PLAIN_B}${bannerText}${lineColor} │\n╰${line}╯"
  echo -e "\n${banner}\n${RESET}"
}

# Explain to the user what changes will be made
make_intro () {
  C2="\033[0;35m"
  C3="\x1b[2m"
  echo -e "${CYAN_B}The seup script will do the following:${RESET}\n"\
  "${C2}(1) Pre-Setup Tasls\n"\
  "  ${C3}- Check that all requirements are met, and system is compatible\n"\
  "  ${C3}- Sets environmental variables from params, or uses sensible defaults\n"\
  "  ${C3}- Output welcome message and summary of changes\n"\
  "${C2}(2) Setup Dotfiles\n"\
  "  ${C3}- Clone or update dotfiles from git\n"\
  "  ${C3}- Symlinks dotfiles to correct locations\n"\
  "${C2}(3) Install packages\n"\
  "  ${C3}- On MacOS, prompt to install Homebrew if not present\n"\
  "  ${C3}- On MacOS, updates and installs apps liseted in Brewfile\n"\
  "  ${C3}- On Arch Linux, updates and installs packages via Pacman\n"\
  "  ${C3}- On Debian Linux, updates and installs packages via apt get\n"\
  "  ${C3}- On Linux desktop systems, prompt to install desktop apps via Flatpak\n"\
  "  ${C3}- Checks that OS is up-to-date and critical patches are installed\n"\
  "${C2}(4) Configure system\n"\
  "  ${C3}- Setup Vim, and install / update Vim plugins via Plug\n"\
  "  ${C3}- Setup Tmux, and install / update Tmux plugins via TPM\n"\
  "  ${C3}- Setup ZSH, and install / update ZSH plugins via Antigen\n"\
  "  ${C3}- Apply system settings (via NSDefaults on Mac, dconf on Linux)\n"\
  "  ${C3}- Apply assets, wallpaper, fonts, screensaver, etc\n"\
  "${C2}(5) Finishing Up\n"\
  "  ${C3}- Refresh current terminal session\n"\
  "  ${C3}- Print summary of applied changes and time taken\n"\
  "  ${C3}- Exit with appropriate status code\n\n"\
  "${PURPLE}You will be prompted at each stage, before any changes are made.${RESET}\n"\
  "${PURPLE}For more info, see GitHub: \033[4;35mhttps://github.com/${REPO_NAME}${RESET}"
}

# Checks if command / package (in $1) exists and then shows
# either shows a warning or error, depending if package required ($2)
system_verify () {
  if ! command_exists $1; then
    if $2; then
      echo -e "🚫 ${RED_B}Error:${PLAIN_B} $1 is not installed${RESET}"
      terminate
    else
      echo -e "⚠️  ${YELLOW_B}Warning:${PLAIN_B} $1 is not installed${RESET}"
    fi
  fi
}

# Prints welcome banner, verifies that requirements are met
function pre_setup_tasks () {
  # Show pretty starting banner
  make_banner "${TITLE}" "${CYAN_B}" 1

  # Set term title
  echo -e "\033];${TITLE}\007\033]6;1;bg;red;brightness;30\a" \
  "\033]6;1;bg;green;brightness;235\a\033]6;1;bg;blue;brightness;215\a"

  # Print intro, listing what changes will be applied
  make_intro

  # Confirm that the user would like to proceed
  echo -e "\n${CYAN_B}Are you happy to continue? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_start
  if [[ ! $ans_start =~ ^[Yy]$ ]] && [[ $AUTO_YES != true ]] ; then
    echo -e "\n${PURPLE}No worries, feel free to come back another time."\
    "\nTerminating...${RESET}"
    make_banner "🚧 Installation Aborted" ${YELLOW_B} 1
    exit 0
  fi
  echo

  # If pre-requsite packages not found, prompt to install
  if ! command_exists git; then
    bash <(curl -s  -L 'https://alicia.url.lol/prerequisite-installs') $PARAMS
  fi

  # Verify required packages are installed
  system_verify "git" true
  system_verify "zsh" false
  system_verify "vim" false
  system_verify "nvim" false
  system_verify "tmux" false

  # If XDG variables arn't yet set, then configure defaults
  if [ -z ${XDG_CONFIG_HOME+x} ]; then
    echo -e "${YELLOW_B}XDG_CONFIG_HOME is not yet set. Will use ~/.config${RESET}"
    export XDG_CONFIG_HOME="${HOME}/.config"
  fi
  if [ -z ${XDG_DATA_HOME+x} ]; then
    echo -e "${YELLOW_B}XDG_DATA_HOME is not yet set. Will use ~/.local/share${RESET}"
    export XDG_DATA_HOME="${HOME}/.local/share"
  fi

  # Ensure dotfiles source directory is set and valid
  if [[ ! -d "$SRC_DIR" ]] && [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${YELLOW_B}Destination direcory not set,"\
    "defaulting to $HOME/.dotfiles\n"\
    "${CYAN_B}To specify where you'd like dotfiles to be downloaded to,"\
    "set the DOTFILES_DIR environmental variable, and re-run.${RESET}"
    DOTFILES_DIR="${HOME}/.dotfiles"
  fi
}


# Downloads / updates dotfiles and symlinks them
function setup_dot_files () {

  # If dotfiles not yet present, clone the repo
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${PURPLE}Dotfiles not yet present."\
    "Downloading ${REPO_NAME} into ${DOTFILES_DIR}${RESET}"
    echo -e "${YELLOW_B}You can change where dotfiles will be saved to,"\
    "by setting the DOTFILES_DIR env var${RESET}"
    mkdir -p "${DOTFILES_DIR}" && \
    git clone --recursive ${DOTFILES_REPO} ${DOTFILES_DIR} && \
    cd "${DOTFILES_DIR}"
  else # Dotfiles already downloaded, just fetch latest changes
    echo -e "${PURPLE}Pulling changes from ${REPO_NAME} into ${DOTFILES_DIR}${RESET}"
    cd "${DOTFILES_DIR}" && \
    git pull origin main && \
    echo -e "${PURPLE}Updating submodules${RESET}" && \
    git submodule update --recursive --remote --init
  fi

  # If git clone / pull failed, then exit with error
  if ! test "$?" -eq 0; then
    echo -e >&2 "${RED_B}Failed to fetch dotfiles from git${RESET}"
    terminate
  fi

  # Set up symlinks with dotbot
  echo -e "${PURPLE}Setting up Symlinks${RESET}"
  cd "${DOTFILES_DIR}"
  git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
  git submodule update --init --recursive "${DOTBOT_DIR}"
  chmod +x  submodules/dotbot/bin/dotbot
  "${DOTFILES_DIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${DOTFILES_DIR}" -c "${SYMLINK_FILE}" "${@}"
}

# Based on system type, uses appropriate package manager to install / updates apps
function install_packages () {
  echo -e "\n${CYAN_B}Would you like to install / update system packages? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_syspackages
  if [[ ! $ans_syspackages =~ ^[Yy]$ ]] && [[ $AUTO_YES != true ]] ; then
    echo -e "\n${PURPLE}Skipping package installs${RESET}"
    return
  fi
  if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    # Mac OS
    intall_macos_packages
  elif [ -f "/etc/arch-release" ]; then
    # Arch Linux
    arch_pkg_install_script="${DOTFILES_DIR}/scripts/arch-pacman.sh"
    chmod +x $arch_pkg_install_script
    $arch_pkg_install_script $PARAMS
  elif [ -f "/etc/debian_version" ]; then
    # Debian / Ubuntu
    debian_pkg_install_script="${DOTFILES_DIR}/scripts/debian-apt.sh"
    chmod +x $debian_pkg_install_script
    $debian_pkg_install_script $PARAMS
  fi
  # If running in Linux desktop mode, prompt to install desktop apps via Flatpak
  flatpak_script="${DOTFILES_DIR}/scripts/flatpak.sh"
  if [[ $SYSTEM_TYPE == "Linux" ]] && [ ! -z $XDG_CURRENT_DESKTOP ] && [ -f $flatpak_script ]; then
    chmod +x $flatpak_script
    $flatpak_script $PARAMS
  fi
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

  # Prompt user to update ZSH, Tmux and Vim plugins, then reload each
  echo -e "\n${CYAN_B}Would you like to install / update ZSH, Tmux and Vim plugins? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_cliplugins
  if [[ $ans_cliplugins =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    # Install / update vim plugins with Plug
    echo -e "\n${PURPLE}Installing Vim Plugins${RESET}"
    vim +PlugInstall +qall

    # Install / update Tmux plugins with TPM
    echo -e "${PURPLE}Installing TMUX Plugins${RESET}"
    chmod ug+x "${XDG_DATA_HOME}/tmux/tpm"
    sh "${TMUX_PLUGIN_MANAGER_PATH}/tpm/bin/install_plugins"
    sh "${XDG_DATA_HOME}/tmux/plugins/tpm/bin/install_plugins"

    # Install / update ZSH plugins with Antigen
    echo -e "${PURPLE}Installing ZSH Plugins${RESET}"
    /bin/zsh -i -c "antigen update && antigen-apply"
  fi

	}

pre_setup_tasks   # Print start message, and check requirements are met
setup_dot_files   # Clone / update dotfiles, and create the symlinks
install_packages  # Prompt to install / update OS-specific packages
apply_preferences
