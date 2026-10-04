# Taurs setup

Sets up a Windows machine for Taurs development. In PowerShell (not as administrator):

```
irm https://raw.githubusercontent.com/seemantmsingh/taurs-setup/main/setup.ps1 | iex
```

It installs Git and the GitHub CLI, asks you to sign in to GitHub, then downloads and runs
the full setup from the private Taurs repository. Your GitHub account needs access to that
repository. This repository holds only that starter: no secrets and no Taurs code.
