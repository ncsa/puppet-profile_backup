# profile_backup

![pdk-validate](https://github.com/ncsa/puppet-profile_backup/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_backup/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure NCSA Service backups


## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_backup](#setup)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile customizes a host to install and configure ICI-ASD's service backups. 
See https://wiki.ncsa.illinois.edu/display/ICI/NCSA+Service+Backups


## Setup

### Backup Clients

Generally only clients that use a **puppet profile** class that needs backups should be configured for backups. 
So to setup a backup client in a **puppet profile** class for a service 1) include `profile_backup::client` and 2) add a backup job:
```
if ( lookup('profile_backup::client::enabled') ) {
  include ::profile_backup::client

  profile_backup::client::add_job { 'jobname':
    paths             => [ '/directory1', '/tmp/directory2.tar', ],
    prehook_commands  => [ 'tar cf /tmp/directory2.tar /directory2', ],
    posthook_commands => [ 'rm -f /tmp/directory2.tar', ],
  }
}
```

The backup clients will need the following parameters supplied:
```yaml
profile_backup::client::encryption_passphrase: "CHANGE ME"  # PREFERABLY IN EYAML
profile_backup::client::server_user: "backup"
profile_backup::client::servers:
  - "backup1.local"
  - "backup2.local"
profile_backup::client::ssh_key_priv: "SSH PRIVATE KEY CONTENTS"  # PREFERABLY IN EYAML
profile_backup::client::ssh_key_pub:  "SSH PUBLIC KEY CONTENTS"   # PREFERABLY IN EYAML
profile_backup::client::ssh_key_type: "ssh-ed25519"
```

If for some reason you want to disable backups, the following parameter should be set:
```yaml
profile_backup::client::enabled: false
```

### Backup Servers

To setup a new backup server include profile_backup in a puppet profile file:
```
include ::profile_backup::server
```

The backup servers will need the following parameters supplied:
```yaml
profile_backup::server::backup_directory: "/backups"
profile_backup::server::clients:  # ONLY FOR CLIENT HOSTS NOT EXPORTING CONFIGS
  "example client localhost":
    hostname: "localhost"
    ip: "127.0.0.1"
    ssh_key_pub: "AAAAB.EXAMPLE.SSH.PUBLIC.KEY"
    ssh_key_type: "ssh-rsa"
profile_backup::server::gid: "202"
profile_backup::server::groupname: "nobody"
profile_backup::server::uid: "9999"
profile_backup::server::username: "backup"
```

If multiple backup servers are setup, `$profile_backup::server::backup_directory` needs to be mounted from a remote or distributed filesystem. The `$profile_backup::server::allow_client_requires` parameter provides a way to add adhoc resource requirements that can be used to ensure the remote filesystem is mounted before attempting to write to it.


## Dependencies

- [ncsa/pam_access](https://github.com/ncsa/puppet-pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/modules/puppetlabs/firewall)


## Reference

See: [REFERENCE.md](REFERENCE.md)
