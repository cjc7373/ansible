# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

## Install archlinux
`ansible-playbook playbooks/install-arch.yml -l $host`

## Vault
The vault password is saved to KeePass through Freedesktop Secret Service.

Generating password using `head -c 64 /dev/urandom | base64 -w 0`.

Saving password using `keyring set ansible default` (which is provided by python-keyring libaray).

## TODO
- backup (maybe borg?)
- should I do a system upgrade everytime when I execute a playbook?
- make use of the until loop.. The `pacman -Sy` seems to be flaky
- use `debug` mode to print messages during execution

## Notes
- Idempotence is IMPORTANT! Think about it when adding a task.
