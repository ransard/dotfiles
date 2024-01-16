#!/bin/sh

# exit on errors
set -e

# print usage information and exit
print_usage() {
    >&2 echo \
"Usage: $(basename $0) [OPTIONS]
Apply (parts of) the configuration to the system.

Available options (at least one required):
  -a    Apply all of the configuration, equivalent to -slpfn
  -s    Install git submodules
  -l    Create symlinks for configuration files and directories
  -p    Install packages listed in packages.txt using paru
  -n    Setup neovim and install neovim plugins
  -f    Setup fish and install fish plugins
  -h    Show this help message"
    exit 0
}

# output message to stderr
print_debug() {
    >&2 echo "$1"
}

# print error message and exit
print_error() {
	if [ "$#" -gt 0 ]; then
		>&2 echo "$1"
	fi
	>&2 echo "Use \"$(basename $0) -h\" for further information."
	exit 1
}


# commands and directories
ln_cmd="ln -sf"
config_dir="$HOME/.config"
dot_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# flags to be set
create_links=false
setup_nvim=false

# set flags according to input parameters
while getopts "aslpfnh" arg; do
    case $arg in
        "a") install_submodules=true create_links=true; install_packages=true;
             setup_fish=true; setup_nvim=true ;;
        "l") create_links=true ;;
        "p") install_packages=true ;;
        "n") setup_nvim=true ;;
        "h") print_usage; exit 0 ;;
        "?") print_error; exit 1 ;;
    esac
done

# test if at least one flag was specified
if [ "$OPTIND" -eq 1 ]; then
    print_error "No options specified."
fi
shift $(( OPTIND - 1 ))

# setup neovim
if [ "$setup_nvim" = true ]; then
    print_debug "Setting up neovim..."
    $ln_cmd "$dot_dir/astronvim" "$config_dir/"
    if [ -d "$config_dir/nvim" ]; then
        rm -rf "$config_dir/nvim"
    fi
    git clone https://github.com/AstroNvim/AstroNvim "$config_dir/nvim"
    nvim --headless -c 'AstroUpdate' -c 'quitall' 2> /dev/null
    print_debug ""
fi
