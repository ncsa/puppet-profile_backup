# @summary Configure backup server
#
# @param additional_sshd_match_params
#   Hash of additional sshd match parameters.
#   Passed to `sshd::allow_from` defined type from `profile_backup::server::allow_client`.
#
# @param allow_client_requires
#   Optional list of resources requirements (e.g. mounts) that should be present before
#   the `allow_client` type is ensured. Should be in the form that would
#   be specified as a `require` array, e.g.:
#   ```
#   - "File[file1]"
#   - "Package[package1]"
#   ```
#
# @param backup_directory
#   Directory path where backups are stored for each client.
#
# @param clients
#   Some clients will need to be manually configured for access to the servers.
#   Backup clients that are using the same PuppetDB server as used by the backup servers should 
#   not need to be added here as those are added via 'exported resources'.
#   This is a hash that contains all the parameters for `profile_backup::server::allow_client`:
#   ```yaml
#   profile_backup::server::clients:
#     client1:
#       hostname: "client1.local"
#       ip: "172.1.2.3"
#       ssh_key_pub: "AAAAB..."  # PUBLIC KEY
#       ssh_key_type: "ssh-rsa"  # ENCRYPTION TYPE
#   ```
#
# @param gid
#   Group id of user that owns backup files.
#
# @param groupname    
#   Groupname that owns backup files.
#
# @param uid
#   User id of user that owns backup files.
#
# @param username
#   Username that owns backup files and allowed access.
#
# @example
#   include profile_backup::server
class profile_backup::server (
  Hash   $additional_sshd_match_params,
  Array[String] $allow_client_requires,
  String $backup_directory,
  Hash   $clients,
  String $gid,
  String $groupname,
  String $uid,
  String $username,
) {
  if empty($gid) or empty($uid) {
    fail('You must provide both gid and uid parameters in class profile_backup::server.')
  }

  include profile_backup::common

  $dir_defaults = {
    ensure => directory,
    group  => $gid,
    owner  => $uid,
  }

  # SETUP BACKUP USER & GROUP
  group { $groupname:
    ensure => 'present',
    gid    => $gid,
  }

  user { $username:
    ensure   => 'present',
    uid      => $uid,
    gid      => $gid,
    home     => $backup_directory,
    password => '!!',
    shell    => '/bin/bash',
    comment  => 'NCSA Service Backups',
  }

  # COLLECT EXPORTED RESOURCES FOR backup_allow_client_on_server
  Profile_backup::Server::Allow_client <<| tag == 'profile_backup_allow_client' |>>

  # ENSURE MANUALY SPECIFIED RESOURCES (FROM HIERA) FOR CLIENTS USING DIFFERENT PUPPET SERVER
  $clients.each |$key, $value| {
    profile_backup::server::allow_client { $key: * => $value }
  }
}
