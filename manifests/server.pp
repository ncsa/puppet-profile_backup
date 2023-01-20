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
#   Clients that need to be manually configured.
#   Backup clients that are using the same Puppet server should not need to
#   be added here as those are added via 'exported resources' via PuppetDB.
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
  include profile_backup::common

  if ($gid) and ($uid) {
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
      #forcelocal     => true,
      home     => $backup_directory,
      password => '!!',
      #purge_ssh_keys => true,
      shell    => '/bin/bash',
      comment  => 'NCSA Service Backups',
    }

    # COLLECT EXPORTED RESOURCES FOR backup_allow_client_on_server
    Profile_backup::Server::Allow_client <<| tag == 'profile_backup_allow_client' |>>

    # ENSURE MANUALY SPECIFIED RESOURCES (FROM HIERA) FOR CLIENTS USING DIFFERENT PUPPET SERVER
    $clients.each |$key, $value| {
      profile_backup::server::allow_client { $key: * => $value }
    }
  } elsif $gid {
    # we've specified $gid but NOT $uid
    fail('You must provide both gid and uid. You provided only gid.')
  } elsif $uid {
    # we've specified $uid but NOT $gid
    fail('You must provide both gid and uid. You provided only uid.')
  } else {
    # we've specified neither $gid nor $uid
    fail('You must provide both gid and uid. You provided neither.')
  }
}
