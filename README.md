# profile_backup

![pdk-validate](https://github.com/ncsa/puppet-profile_backup/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_backup/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure NCSA Service backups

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


## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.


## Dependencies

- [ncsa/pam_access](https://github.com/ncsa/puppet-pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/modules/puppetlabs/firewall)
- nfs server


## Reference

See: [REFERENCE.md](REFERENCE.md)
