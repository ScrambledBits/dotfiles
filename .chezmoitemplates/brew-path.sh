# Ensure brew is on PATH (chezmoi does not source shell profiles). Shared by
# every run_* script that calls a brew-installed binary; covers both darwin
# prefixes and both linuxbrew locations (shared install, per-user fallback).
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
else
    echo "ERROR: Homebrew not found. Run chezmoi apply again after installing Homebrew." >&2
    exit 1
fi
