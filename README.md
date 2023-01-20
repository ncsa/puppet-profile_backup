# profile_backup

![pdk-validate](https://github.com/ncsa/puppet-profile_backup/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_backup/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure NCSA Service backups

> :warning: **This is work in progress**: Currently only the `::profile_backup::server` logic is functional.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_backup](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile customizes a host to install and configure ICI-ASD's service backups. 
See https://wiki.ncsa.illinois.edu/display/ICI/NCSA+Service+Backups


## Setup

### Backup Clients

To setup a backup client include profile_backup in a puppet profile file for a service:
```
include ::profile_backup::client
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

If multiple backup servers are setup, `$profile_backup::server::backup_directory` needs to be mounted from a remote or distributed filesystem. The `$profile_backup::server::allow_client_requires` parameter provides a way to add adhod resource requirements that can be used to ensure the remote filesystem is mounted before attempting to write to it.

## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.


## Dependencies

- [ncsa/pam_access](https://github.com/ncsa/puppet-pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/modules/puppetlabs/firewall)


## Reference

See: [REFERENCE.md](REFERENCE.md)
