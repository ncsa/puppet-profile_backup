# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`profile_backup`](#profile_backup): Install and configure NCSA Service Backups for clients and backup servers
* [`profile_backup::client`](#profile_backupclient): Configure backup client
* [`profile_backup::common`](#profile_backupcommon): Configure common things for both backup clients and servers.
* [`profile_backup::server`](#profile_backupserver): Configure backup server

### Defined types

* [`profile_backup::server::allow_client`](#profile_backupserverallow_client): Enable backup client to access backup server

## Classes

### <a name="profile_backup"></a>`profile_backup`

See: https://wiki.ncsa.illinois.edu/display/ICI/NCSA+Server+Backup

This class should never be included. Only one of the following
should be included, depending on the role:
- backup client: `include profile_backup::client`
- backup server: `include profile_backup::server`

#### Examples

##### 

```puppet
include profile_backup::client
```

### <a name="profile_backupclient"></a>`profile_backup::client`

Configure backup client

#### Examples

##### 

```puppet
include profile_backup::client
```

#### Parameters

The following parameters are available in the `profile_backup::client` class:

* [`ssh_key_priv`](#ssh_key_priv)
* [`ssh_key_pub`](#ssh_key_pub)
* [`ssh_key_type`](#ssh_key_type)

##### <a name="ssh_key_priv"></a>`ssh_key_priv`

Data type: `String`

The private ssh key itself; generally a very long string...

##### <a name="ssh_key_pub"></a>`ssh_key_pub`

Data type: `String`

The public ssh key itself; generally a long string...

##### <a name="ssh_key_type"></a>`ssh_key_type`

Data type: `String`

The encryption type used in the ssh key.

### <a name="profile_backupcommon"></a>`profile_backup::common`

Configure common things for both backup clients and servers.

#### Examples

##### 

```puppet
include profile_backup::common
```

#### Parameters

The following parameters are available in the `profile_backup::common` class:

* [`packages`](#packages)
* [`pip_config`](#pip_config)
* [`pip_proxy`](#pip_proxy)

##### <a name="packages"></a>`packages`

Data type: `Hash`

Packages to install to support the backup service.

##### <a name="pip_config"></a>`pip_config`

Data type: `String`

Path to pip config file

##### <a name="pip_proxy"></a>`pip_proxy`

Data type: `String`

Optional proxy server for pip configuration

### <a name="profile_backupserver"></a>`profile_backup::server`

Configure backup server

#### Examples

##### 

```puppet
include profile_backup::server
```

#### Parameters

The following parameters are available in the `profile_backup::server` class:

* [`additional_sshd_match_params`](#additional_sshd_match_params)
* [`allow_client_requires`](#allow_client_requires)
* [`backup_directory`](#backup_directory)
* [`clients`](#clients)
* [`gid`](#gid)
* [`groupname`](#groupname)
* [`uid`](#uid)
* [`username`](#username)

##### <a name="additional_sshd_match_params"></a>`additional_sshd_match_params`

Data type: `Hash`

Hash of additional sshd match parameters.
Passed to `sshd::allow_from` defined type from `profile_backup::server::allow_client`.

##### <a name="allow_client_requires"></a>`allow_client_requires`

Data type: `Array[String]`

Optional list of resources requirements (e.g. mounts) that should be present before
the `allow_client` type is ensured. Should be in the form that would
be specified as a `require` array, e.g.:
```
- "File[file1]"
- "Package[package1]"
```

##### <a name="backup_directory"></a>`backup_directory`

Data type: `String`

Directory path where backups are stored for each client.

##### <a name="clients"></a>`clients`

Data type: `Hash`

Clients that need to be manually configured.
Backup clients that are using the same Puppet server should not need to
be added here as those are added via 'exported resources' via PuppetDB.
This is a hash that contains all the parameters for `profile_backup::server::allow_client`:
```yaml
profile_backup::server::clients:
  client1:
    hostname: "client1.local"
    ip: "172.1.2.3"
    ssh_key_pub: "AAAAB..."  # PUBLIC KEY
    ssh_key_type: "ssh-rsa"  # ENCRYPTION TYPE
```

##### <a name="gid"></a>`gid`

Data type: `String`

Group id of user that owns backup files.

##### <a name="groupname"></a>`groupname`

Data type: `String`

Groupname that owns backup files.

##### <a name="uid"></a>`uid`

Data type: `String`

User id of user that owns backup files.

##### <a name="username"></a>`username`

Data type: `String`

Username that owns backup files and allowed access.

## Defined types

### <a name="profile_backupserverallow_client"></a>`profile_backup::server::allow_client`

Enable backup client to access backup server

#### Examples

##### 

```puppet
profile_backup::server::allow_client { 'allow host hostname access to backup servers':
  'hostname' => String,
  'ip' => String,
  'ssh_key_pub' => String,
  'ssh_key_type' => String,
}
```

#### Parameters

The following parameters are available in the `profile_backup::server::allow_client` defined type:

* [`hostname`](#hostname)
* [`ip`](#ip)
* [`ssh_key_pub`](#ssh_key_pub)
* [`ssh_key_type`](#ssh_key_type)

##### <a name="hostname"></a>`hostname`

Data type: `String`

fqdn hostname of backup client.

##### <a name="ip"></a>`ip`

Data type: `String`

ip of backup client.

##### <a name="ssh_key_pub"></a>`ssh_key_pub`

Data type: `String`

The public ssh key itself; generally a long string...

##### <a name="ssh_key_type"></a>`ssh_key_type`

Data type: `String`

The encryption type used in the ssh key.
