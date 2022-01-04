# Coherence's infrastructure
Ansible playbooks for my own infrasturcture.
The file hierarchy and some scripts are from [Archlinux's infrasturcture](https://gitlab.archlinux.org/archlinux/infrastructure).

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
- should I do a system upgrade everytime when I execute a playbook?
- make use of the until loop.. The `pacman -Sy` seems to be flaky
- use `debug` mode to print messages during execution
- Could cloudflare be automated? - Sure it can! Use `community.general.cloudflare_dns`.
- For now, the configs management is divided to two parts, my own pc and my VPS. However, I believe they can be merged into one..
- Find some motd scripts, like: https://github.com/yboetz/motd/blob/master/50-fail2ban-status
- Upgrade strategy. For now upgrade is executed manually with `pacman -Syu` and `reboot`.

## Some specific Apps
### Syncthing
Migrate syncthing to a new machine seems to be uneasy.

In my humble opinion, the easiest way is to copy the config (including private key, but excluding the database), and delete and re-add the sync folder manually.

## Backup
There should be at least two backup servers, for the basic redundancy.

The backup procedure is done in a fixed interval and do not need human interference.

I'm wondering if the restore procedure can be automated, or at least documented..

## Notes
- Idempotence is IMPORTANT! Think about it when adding a task.

## Gunicorn
`community.general.gunicorn` doesn't seem to support reload. So I choose to stick on the systemd service.

## Services not controlled with ansible
- los_angeles:
    - go-cqhttp
    - forward-bot
- shanghai_aliyun: (This server is not maintained by ansible and is deprecated)
    - nwuoj
    - as soon as nwuoj is migrated to other servers, this server will be stopped

