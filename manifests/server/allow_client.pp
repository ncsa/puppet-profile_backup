# @summary Enable backup client to access backup server
#
# @param hostname
#   fqdn hostname of backup client.
#
# @param ip
#   ip of backup client.
#
# @param ssh_key_pub
#   The public ssh key itself; generally a long string...
#
# @param ssh_key_type
#   The encryption type used in the ssh key.
#
# @example
#   profile_backup::server::allow_client { 'allow host hostname access to backup servers':
#     'hostname' => String,
#     'ip' => String,
#     'ssh_key_pub' => String,
#     'ssh_key_type' => String,
#   }
define profile_backup::server::allow_client (
  String $hostname,
  String $ip,
  String $ssh_key_pub,
  String $ssh_key_type,
) {
  # SET DEFAULTS FOR CLIENT
  $repo_path = "${profile_backup::server::backup_directory}/${hostname}"

  # SETUP SSHD MATCHBLOCK, PAM ACCESS, & FIREWALL FOR CLIENT
  ::sshd::allow_from { $name:
    additional_match_params => $profile_backup::server::additional_sshd_match_params,
    hostlist                => [$ip],
    users                   => [$profile_backup::server::username],
  }

  # SETUP SSH AUTHORIZED KEY ENTRY FOR CLIENT
  ssh_authorized_key { $hostname:
    ensure  => present,
    key     => Sensitive($ssh_key_pub),
    # SEE https://borgbackup.readthedocs.io/en/stable/quickstart.html#remote-repositories
    options => [
      "from=\"${ip}\"",
      "command=\"borg serve --restrict-to-path ${repo_path}\"",
      'restrict',
    ],
    type    => $ssh_key_type,
    user    => $profile_backup::server::username,
    require => $profile_backup::server::allow_client_requires,
  }

  # ENSURE REPOSITORY DIRECTORY FOR THIS CLIENT
  file { $repo_path:
    ensure  => directory,
    group   => $profile_backup::server::gid,
    mode    => '0700',
    owner   => $profile_backup::server::uid,
    require => $profile_backup::server::allow_client_requires,
  }
}
