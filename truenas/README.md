Non-ansible provisioned. Related to my truenas configuration.

## immich
To expose immich to athena, add a caddy file to `/etc/caddy/conf.d/`:

```
photos.coherence.space {
    reverse_proxy apollo:10041
    log {
            output file /var/log/caddy/immich_access.log
            format console
    }
}
```

Then reload caddy service.
