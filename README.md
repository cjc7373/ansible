# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

## Run a playbook
`ansible-playbook some_playbook.yml`

For some roles, pass a varible `update` with any value to upgrade the service. Like `ansible-playbook some_playbook.yml -e update=t`
(`-e` equals to `--extra-vars`)

## Standard Procedure For A New Machine
- If the login user is not root, make sure we can login with root.
- Add this machine to inventory list, which is `./hosts`.
- Run `ansible-playbook playbooks/install_arch.yml -l [host_name] -v --ask-pass`
- Input the root password.
- Double confirm installation when playbook is paused.
- install iptables-nft (it conflicts with iptables so that it can't be installed automatically)

The playbook will have a warning:
`[WARNING]: sftp transfer mechanism failed on [test.nwu.icu]. Use ANSIBLE_DEBUG=1 to see detailed information`

But it seems this did not affect anything. To be investigated..

The playbook will also get stuck on the final step, use Ctrl+C to exit.

## Vault
The vault password is saved to KeePass through Freedesktop Secret Service.

Generating password using `head -c 64 /dev/urandom | base64 -w 0`.

Saving password using `keyring set ansible default` (which is provided by python-keyring libaray).

### Some operations
- View/Edit/Create an encrypted file: `ansible-vault view/edit/create foo.yml`
- Encrypt/decrypt an existing file: `ansible-vault encrypt/decrypt foo.yml`
- View an encrypted variable: `ansible localhost -m debug -a var="new_user_password" -e "@foo.yml"` (`@` is necessary)

## TODO
- backup (maybe borg?)
- make use of the until loop.. The `pacman -Sy` seems to be flaky
- use `debug` mode to print messages during execution
- Could cloudflare be automated? - Sure it can! Use `community.general.cloudflare_dns`.
- For now, the configs management is divided to two parts, my own pc and my VPS. However, I believe they can be merged into one..
- Find some motd scripts, like: https://github.com/yboetz/motd/blob/master/50-fail2ban-status
- Upgrade strategy. For now upgrade is executed manually with `pacman -Syu` and `reboot`.
  Should the system be upgraded every time a playbook runs? Or upgraged only when a specific variable is defined?
- configure docker image mirror
- fix ansible-lint errors

## Issues
- docker-compose module requires docker-compose < 2.0.0, because of a major [rewrite](https://github.com/ansible-collections/community.docker/issues/216).
  This breaks all the docker based roles.
  - After some investigation, I think it's hard to migrate the original `community.docker.docker_compose` module to conform docker-compose 2.0, and my use cases are relatively simple.
    So I decided to use `command` module to invoke compose cli. 
  - FIXME: now the logic is repeated in many roles, need to abstract it.
- ansible-lint in Ansbile VScode extension is not working

## Some specific Apps
### Syncthing
Migrate syncthing to a new machine seems to be uneasy.

In my humble opinion, the easiest way is to copy the config (including private key, but excluding the database), and delete and re-add the sync folder manually.

### Tailscale
Tailscale's NAT traversal techniques work with most firewalls out of the box. I've tested with firewalld and it works as expected. So there is no need to allow some ports manually in firewalld.

Tailscale's auth key expires every 90 days. We need to manually update it.

### Firewalld
It may block docker interfaces.. Docker has support for auto-config firewalld, but this require firewalld running and loading configs before creating containers.
See: https://github.com/moby/libnetwork/pull/2548
https://docs.docker.com/network/iptables/#integration-with-firewalld

Some principles:
- public zone rejects any incoming traffic except some pre-defined services
- for the ease of testing, ports 50000-51000 are open
- trusted zone (which includes tailscale interface) accepts any incoming traffic 

### Authelia
OIDC Endpoints: https://www.authelia.com/integration/openid-connect/introduction/#well-known-discovery-endpoints

## Backup
Backup is done using kopia.

The backup procedure is done in a fixed interval and do not need human interference.

Currently, the setup process is done manually. It is as following:
- `kopia repository connect webdav --url http://apollo:10015/backup/kopia --webdav-username xxx --webdav-password xxx`
- Enter repo password (stored in keepass)
- Modify `.config/kopia/repository.config` change `enableActions` to true
- Refer to https://kopia.io/docs/advanced/actions to set actions
- `kopia policy set --keep-daily 30 --global` this option should apply to every client (?)

### reference
prometheus:
- kopia policy set /var/lib/prometheus-longterm/ --before-folder-action "systemctl stop prometheus-longterm.service"
- kopia policy set /var/lib/prometheus-longterm/ --after-folder-action "systemctl start prometheus-longterm.service"
- create systemd service `/etc/systemd/system/prometheus-backup.service`:
```
[Unit]
Description=Backup prometheus-longterm data

[Service]
Type=oneshot
Environment="KOPIA_CONFIG_PATH=/root/.config/kopia/repository.config"
ExecStart=kopia snapshot create /var/lib/prometheus-longterm/
```

- enable timer: `systemctl enable --now daily@prometheus-backup.timer`

postgresql:
- kopia policy set /root/postgresql/data/ --before-folder-action "docker compose -f /root/postgresql/docker-compose.yaml stop"
- kopia policy set /root/postgresql/data/ --after-folder-action "docker compose -f /root/postgresql/docker-compose.yaml start"
- create systemd service `/etc/systemd/system/postgres-backup.service`:
```
[Unit]
Description=Backup postgres data

[Service]
Type=oneshot
Environment="KOPIA_CONFIG_PATH=/root/.config/kopia/repository.config"
ExecStart=kopia snapshot create /root/postgresql/data/
```

- enable timer: `systemctl enable --now daily@postgres-backup.timer`

forgejo:
- kopia policy set /var/lib/forgejo/ --before-folder-action "systemctl stop forgejo.service"
- kopia policy set /var/lib/forgejo/ --after-folder-action "systemctl start forgejo.service"
- create systemd service `/etc/systemd/system/forgejo-backup.service`:
```
[Unit]
Description=Backup forgejo data

[Service]
Type=oneshot
Environment="KOPIA_CONFIG_PATH=/root/.config/kopia/repository.config"
ExecStart=kopia snapshot create /var/lib/forgejo/
```

- enable timer: `systemctl enable --now daily@forgejo-backup.timer`

### Gunicorn
`community.general.gunicorn` doesn't seem to support reload. (Because it runs gunicorn as a daemon) So I choose to stick on the systemd service.

## Services not controlled with ansible

