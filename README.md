# Taurs setup

Sets up a Windows, macOS, or Linux machine for Taurs development, and updates it when run
again.

Windows, in PowerShell (not as administrator):

```
irm https://raw.githubusercontent.com/seemantmsingh/taurs-setup/main/setup.ps1 | iex
```

macOS or Linux, in a terminal (not as root):

```
curl -fsSL https://raw.githubusercontent.com/seemantmsingh/taurs-setup/main/setup.sh | bash
```

It installs Git and the GitHub CLI, asks you to sign in to GitHub, then downloads and runs
the full setup from the private Taurs repository (`scripts/onboard-windows.ps1` or
`scripts/onboard-unix.sh`). Your GitHub account needs access to that repository. This
repository holds only these starters: no secrets and no Taurs code.
