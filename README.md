# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

## Install archlinux
`ansible-playbook playbooks/install-arch.yml -l $host`

## Vault
The vault password is saved to KeePass through Freedesktop Secret Service.
Generating password using `head -c 64 /dev/urandom | base64 -w 0`.
Saving password using `keyring set ansible default`.

## TODO
- 把 install 写成一个 role 是否合理?