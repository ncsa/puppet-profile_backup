# @summary Configure backup client
#
# @param ssh_key_priv
#   The private ssh key itself; generally a very long string...
#
# @param ssh_key_pub
#   The public ssh key itself; generally a long string...
#
# @param ssh_key_type
#   The encryption type used in the ssh key.
#
# @example
#   include profile_backup::client
class profile_backup::client (
  String $ssh_key_priv,
  String $ssh_key_pub,
  String $ssh_key_type,
) {
  include profile_backup::common

  ## TO DO...
  # ENSURE $ssh_key_priv
  # ENSURE $ssh_key_pub
  # ENSURE ENCRYPTION KEY
  # ...

  # EXPORT CLIENT DETAILS TO BACKUP SERVER FOR ACCESS
  @@profile_backup::server::allow_client { "allow host ${facts['networking']['fqdn']} access to backup servers":
    hostname     => $facts['networking']['fqdn'],
    ip           => $facts['networking']['ip'],
    ssh_key_pub  => $ssh_key_pub,
    ssh_key_type => $ssh_key_type,
    tag          => 'profile_backup_allow_client',
  }
}
