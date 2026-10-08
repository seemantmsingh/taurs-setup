#!/usr/bin/env bash
# Taurs setup starter for macOS and Linux. Run in a terminal (not as root):
#
#   curl -fsSL https://raw.githubusercontent.com/seemantmsingh/taurs-setup/main/setup.sh | bash
#
# It installs Git and the GitHub CLI (Homebrew on macOS, installed first when missing; apt or
# dnf on Linux), signs in to GitHub (the Taurs repository is private), then downloads and runs
# the full setup, scripts/onboard-unix.sh, from that repository. Arguments after
# `bash -s --` pass on to it. This file holds no secrets and no Taurs code.
set -euo pipefail

repository='seemantmsingh/taurs'
setup_path='scripts/onboard-unix.sh'

say() { printf '  \033[38;2;125;211;252m%s\033[0m\n' "$1"; }
fail() { printf '\n  \033[38;2;255;209;220m%s\033[0m\n\n' "$1" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

brew_environment() {
  local brew
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then eval "$("$brew" shellenv)"; return 0; fi
  done
  return 1
}

install_macos() {
  if ! brew_environment; then
    say 'Installing Homebrew (it asks for your password)...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_environment || fail 'Homebrew is not on PATH after installing it.'
  fi
  brew install git gh
}

install_apt() {
  sudo apt-get update
  sudo apt-get install -y git curl ca-certificates
  has gh && return 0
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
}

install_tools() {
  if has git && has gh; then return 0; fi
  say 'Installing Git and the GitHub CLI...'
  case "$(uname -s)" in
    Darwin) install_macos ;;
    Linux)
      if has apt-get; then install_apt
      elif has dnf; then sudo dnf install -y git gh
      else fail 'Install Git and the GitHub CLI (https://cli.github.com), then run this again.'
      fi ;;
    *) fail "No Taurs setup is defined for $(uname -s)." ;;
  esac
}

main() {
  printf '\n  \033[1;38;2;125;211;252m\xe2\x97\x88 Taurs setup\033[0m\n'
  printf '  \033[38;2;139;148;158mPreparing: Git, the GitHub CLI, and a GitHub sign-in.\033[0m\n\n'
  [ "$(id -u)" != 0 ] || fail 'Run this as your own user, not as root; it asks for sudo when it needs it.'
  install_tools
  if ! gh auth status >/dev/null 2>&1; then
    say 'A browser window opens: sign in to GitHub and enter the code shown here.'
    gh auth login --hostname github.com --git-protocol https --web
    gh auth status >/dev/null 2>&1 || fail 'GitHub sign-in did not complete.'
  fi
  local setup
  setup="$(mktemp "${TMPDIR:-/tmp}/taurs-setup.XXXXXX")"
  gh api "repos/$repository/contents/$setup_path" -H 'Accept: application/vnd.github.raw' >"$setup" ||
    fail "Downloading the setup failed; check that your GitHub account can read $repository."
  bash "$setup" "$@"
}

# Questions and sign-in read the terminal, not the pipe this script arrives on.
main "$@" </dev/tty
