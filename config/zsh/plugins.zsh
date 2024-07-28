#!/usr/bin/env zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git

# Syntax highlighting for commands
antigen bundle zsh-users/zsh-syntax-highlighting

# Quickly jump into frequently used directories
antigen bundle agkozak/zsh-z

# Auto suggestions from history
antigen bundle zsh-users/zsh-autosuggestions


antigen apply
