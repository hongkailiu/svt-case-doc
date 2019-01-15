# VSCode

[Installation](https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions)

```sh
$ sudo yum history info 48
Loaded plugins: changelog, fs-snapshot, priorities, refresh-packagekit, rhnplugin, rpm-warm-cache, verify
This system is receiving updates from RHN Classic or Red Hat Satellite.
Repository google-chrome is listed more than once in the configuration
Repository google-talkplugin is listed more than once in the configuration
Transaction ID : 48
Begin time     : Sun Sep  9 08:07:23 2018
Begin rpmdb    : 1810:b8a93196bcea802ce7d5b31ca2ed5db4444cb5e1
End time       :            08:07:32 2018 (9 seconds)
End rpmdb      : 1811:14d2aaa4cc8489fa22542c3b931e999e722f00d6
User           : Hongkai Liu <hongkliu>
Return-Code    : Success
Command Line   : install code
Transaction performed with:
    Installed     rpm-4.11.3-25.el7.x86_64                @production-rhel-x86_64-workstation-7.4
    Installed     yum-3.4.3-154.el7.noarch                @production-rhel-x86_64-workstation-7.4
    Installed     yum-metadata-parser-1.1.4-10.el7.x86_64 @CSB-RHEL72-updates/7.2
    Installed     yum-rhn-plugin-2.0.1-9.el7.noarch       @production-rhel-x86_64-workstation-7.4
Packages Altered:
    Install code-1.27.1-1536226249.el7.x86_64 @code
history info


$ code --version
1.27.1

```

## Go plugin
https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go

## code-spell-checker
https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker#overview