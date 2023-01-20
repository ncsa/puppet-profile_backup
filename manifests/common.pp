# @summary Configure common things for both backup clients and servers.
#
# @param packages
#   Packages to install to support the backup service.
#
# @param pip_config
#   Path to pip config file
#
# @param pip_proxy
#   Optional proxy server for pip configuration
#   
# @example
#   include profile_backup::common
class profile_backup::common (
  Hash $packages,
  String $pip_config,
  String $pip_proxy,
) {
  # LONG TERM PROBABLY BETTER TO CONFIGURE PIP/PYTHON FROM ANOTHER MODULE
  # WILL ADDRESS THIS ONCE NEEDED

  # SETUP pip3 PROXY IF NECESSARY
  if (! empty($pip_proxy )) {
    $file_defaults = {
      ensure  => file,
      owner   => root,
      group   => root,
      mode   => '0644',
    }
    ensure_resource( 'file', $pip_config, $file_defaults )
    ini_setting { 'set pip proxy':
      ensure  => present,
      path    => $pip_config,
      section => 'global',
      setting => 'proxy',
      value   => $pip_proxy,
      require => [
        File[$pip_config]
      ],
    }
  }

  ensure_resources('package', $packages)
}
