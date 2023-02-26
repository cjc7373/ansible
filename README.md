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
- Run `ansible-playbook playbooks/install_arch.yml -l host_name -v --ask-pass`
- Input the root password.
- Double confirm installation when playbook is paused.

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

### Authelia
OIDC Endpoints: https://www.authelia.com/integration/openid-connect/introduction/#well-known-discovery-endpoints

## Backup
There should be at least two backup servers, for the basic redundancy.
Or we could use [BorgBase](https://www.borgbase.com/), which provides borg repositories hosting. 10 GB free space seems to be enough.

The backup procedure is done in a fixed interval and do not need human interference.

I'm wondering if the restore procedure can be automated, or at least documented..

### Gunicorn
`community.general.gunicorn` doesn't seem to support reload. (Because it runs gunicorn as a daemon) So I choose to stick on the systemd service.

## Services not controlled with ansible
- None
