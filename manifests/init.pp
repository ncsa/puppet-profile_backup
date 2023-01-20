# @summary Install and configure NCSA Service Backups for clients and backup servers
#
# See: https://wiki.ncsa.illinois.edu/display/ICI/NCSA+Server+Backup
#
# This class should never be included. Only one of the following
# should be included, depending on the role:
# - backup client: `include profile_backup::client`
# - backup server: `include profile_backup::server`
#
# @example
#   include profile_backup::client
class profile_backup {
  # THIS CLASS IS INTENTIONALLY LEFT EMPTY

  $notify_text = @("EOT"/)
    The top level profile_backup class should not be used.
    Instead use one of the following classes:
      - profile_backup::client
      - profile_backup::server
    | EOT
  notify { $notify_text:
    withpath => true,
    loglevel => 'warning',
  }
}
