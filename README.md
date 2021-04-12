# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

## Install archlinux
`ansible-playbook playbooks/install-arch.yml -l $host -v`

The playbook will end up with:
```
TASK [install_arch : add authorized key for root] ******************************************************************************************************************************************************************************************
[WARNING]: sftp transfer mechanism failed on [test.nwu.icu]. Use ANSIBLE_DEBUG=1 to see detailed information
changed: [test.nwu.icu] => {"changed": true, "comment": null, "exclusive": true, "follow": false, "gid": 0, "group": "root", "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAw6HJZnTrd5DrS6INhgOfQHMasFVffXMzr2BZPq5lqHvg+RNhWSQ1X8LbaOlmsP6EhPiQJcTwTmy7Li2V62kmeqX0BSH4xrdBxd02MZxNWGNtgPtlsZYfKNy7GPLjNUHjySIQ9/8ABtaAGe6ZnHFFdK8DkV5vHGZ9PWCmXj5fH2oTSwuUFEz1vs9LNYyrtEz28A1xbc7A6a1PbOX9XWX6x01ziHj4XFrNlrxN3O3/MJRflb/ktCCedbPJzSnaFcb5qLiv49spop9wqsuIPPdupHYrjArk3g8sYR4cWY2bT24Jwh/M1P+Lgkn2B7DcYDJSEZZZjpuxotIWrRMNOha90w==", "key_options": null, "keyfile": "/root/.ssh/authorized_keys", "manage_dir": true, "mode": "0600", "owner": "root", "path": "/root/.ssh/authorized_keys", "size": 382, "state": "file", "uid": 0, "user": "root", "validate_certs": true}                                                                                                                                                                                                    

TASK [install_arch : change root password to a random string] ******************************************************************************************************************************************************************************
[WARNING]: sftp transfer mechanism failed on [test.nwu.icu]. Use ANSIBLE_DEBUG=1 to see detailed information
changed: [test.nwu.icu] => {"changed": true, "cmd": "head -c 32 /dev/urandom | base64 | sed 's/^/root:/' | chpasswd", "delta": "0:00:00.019011", "end": "2021-04-12 07:28:36.859597", "rc": 0, "start": "2021-04-12 07:28:36.840586", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}                                                                                                                                                                               

TASK [install_arch : reboot] ***************************************************************************************************************************************************************************************************************
[WARNING]: sftp transfer mechanism failed on [test.nwu.icu]. Use ANSIBLE_DEBUG=1 to see detailed information
fatal: [test.nwu.icu]: FAILED! => {"changed": false, "elapsed": 0, "msg": "Reboot command failed. Error was System has not been booted with systemd as init system (PID 1). Can't operate.\r\nFailed to connect to bus: Host is down\r\nSystem has not been booted with systemd as init system (PID 1). Can't operate.\r\nFailed to connect to bus: Host is down\r\nFailed to talk to init daemon., Shared connection to test.nwu.icu closed.", "rebooted": false, "start": "2021-04-12T07:28:43.199867"}
```
But in fact the insall process succeeded. To be investigated..

## Vault
The vault password is saved to KeePass through Freedesktop Secret Service.

Generating password using `head -c 64 /dev/urandom | base64 -w 0`.

Saving password using `keyring set ansible default` (which is provided by python-keyring libaray).

## TODO
- backup (maybe borg?)
- should I do a system upgrade everytime when I execute a playbook?
- make use of the until loop.. The `pacman -Sy` seems to be flaky
- use `debug` mode to print messages during execution
- Could cloudflare be automated? - Sure it can! Use `community.general.cloudflare_dns`.
- how to manage syncthing?
- Timezone

## Backup
There should be at least two backup servers, for the basic redundancy.

The backup procedure is done in a fixed interval and do not need human interference.

I'm wondering if the restore procedure can be automated, or at least documented..

## Notes
- Idempotence is IMPORTANT! Think about it when adding a task.

## Gunicorn
`community.general.gunicorn` doesn't seem to support reload. So I choose to stick on the systemd service.
