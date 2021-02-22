# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

先把安装部分跳过吧..
## Install archlinux
`ansible-playbook playbooks/install-arch.yml -l $host`

## TODO
- 把 install 写成一个 role 是否合理?