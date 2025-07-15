# Steps :
## 1) Open Powershell as Adminstrator and run below command :
```
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## 2) Varify choco version:
```
choco --version
```
## 3) List all packages Installed using Chocolaty:
```
choco list
```
## 4) Search for a package :
```
choco search <name>
```
## 5) Upgrade all installed packages :
```
choco upgrade all -y
```
