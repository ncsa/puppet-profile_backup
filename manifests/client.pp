# @summary Configure backup client
#
# @param enabled
#   Abitilty to enable/disable backups
#
# @param encryption_passphrase
#   Encryption passphrase used by the client's backups
#
# @param job_cron_schedule
#   Cron settings for backup jobs
#
# @param prune_settings
#   Settings used for pruning client's backup data
#
# @param server_user
#   User that client connects to backup server as
#
# @param servers
#   List of backup servers that client can backup to
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
# @param verify_cron_schedule
#   Cron settings for backup verification
#
# @param work_directory
#   Directory path where backup scripts and jobs are located
#
# @example
#   include profile_backup::client
class profile_backup::client (
  Boolean $enabled,
  String $encryption_passphrase,
  Hash $job_cron_schedule,
  Hash $prune_settings,
  String $server_user,
  Array[String] $servers,
  String $ssh_key_priv,
  String $ssh_key_pub,
  String $ssh_key_type,
  Hash $verify_cron_schedule,
  String $work_directory,
) {
  if ( $enabled) {
    include profile_backup::common

    # Local variables
    $sshdir = '/root/.ssh'
    $telegraf_interval = '1h'
    $telegraf_interval_date_string = '1 hour ago'

    # PREDICTIVELY RANDOMIZE LIST OF BACKUP $servers
    $server_random_order_based_on_fqdn = fqdn_rotate($servers, $facts['networking']['mac'])
    $server_list = $server_random_order_based_on_fqdn.join(' ')

    $ssh_file_defaults = {
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      require => File[$sshdir],
    }

    # Define unique parameters of each resource
    $ssh_file_data = {
      $work_directory => {
        ensure => directory,
        mode   => '0700',
        require => [],
      },
      $sshdir => {
        ensure => directory,
        mode   => '0700',
        require => [],
      },
      "${sshdir}/backup_id_${ssh_key_type}" => {
        content => Sensitive($ssh_key_priv),
      },
      "${sshdir}/backup_id_${ssh_key_type}.pub" => {
        content => Sensitive("${ssh_key_type} ${ssh_key_pub} backup@${facts['networking']['fqdn']}\n"),
        mode    => '0644',
      },
    }

    # Ensure the ssh file resources
    ensure_resources( 'file', $ssh_file_data, $ssh_file_defaults )

    # Ensure borg_defaults file and settings
    # CONVERT $prune_settings HASH TO $prune_options_string
    $prune_options_string = $prune_settings
    .map | $key, $value | { "--${key} ${value}" }
    .join(' ')

    $backup_file_defaults = {
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0700',
      require => File[$work_directory],
    }

    # Define unique parameters of each resource
    $backup_file_data = {
      $work_directory => {
        ensure => directory,
        require => [],
      },
      "${work_directory}/borg_defaults.sh" => {
        content => template('profile_backup/borg_defaults.sh.erb'),
      },
      "${work_directory}/borg_check.sh" => {
        content => template('profile_backup/borg_check.sh.erb'),
      },
      "${work_directory}/borg_list.sh" => {
        content => template('profile_backup/borg_list.sh.erb'),
      },
      "${work_directory}/borg_backup_job.sh" => {
        content => template('profile_backup/borg_backup_job.sh.erb'),
      },
      "${work_directory}/borg_backup_cmd_job.sh" => {
        content => template('profile_backup/borg_backup_cmd_job.sh.erb'),
      },
      "${work_directory}/cron_do_backup.sh" => {
        content => template('profile_backup/cron_do_backup.sh.erb'),
      },
      "${work_directory}/cron_check_backup.sh" => {
        content => template('profile_backup/cron_check_backup.sh.erb'),
      },
    }
    # Ensure the backup file resources
    ensure_resources( 'file', $backup_file_data, $backup_file_defaults )

    # SETUP RSYSLOG TO WATCH THE last_run FILES

    # MONITORING VIA TELEGRAF
    file { '/etc/telegraf/scripts/backup.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'telegraf',
      mode    => '0750',
      content => template('profile_backup/telegraf_backup.sh.erb'),
    }
    telegraf::input { 'backup':
      plugin_type => 'exec',
      options     => [
        {
          command     => '/etc/telegraf/scripts/backup.sh',
          data_format => 'influx',
          interval    => $telegraf_interval,
          timeout     => '30s',
        },
      ],
      require     => [
        File['/etc/telegraf/scripts/backup.sh'],
      ],
    }

    # EXPORT CLIENT DETAILS TO BACKUP SERVER FOR ACCESS
    @@profile_backup::server::allow_client { "allow host ${facts['networking']['fqdn']} access to backup servers":
      hostname     => $facts['networking']['fqdn'],
      ip           => $facts['networking']['ip'],
      ssh_key_pub  => $ssh_key_pub,
      ssh_key_type => $ssh_key_type,
      tag          => 'profile_backup_allow_client',
    }

    $cron_ensure = 'present'
  } else {
    $cron_ensure = 'absent'
  }

  # BACKUP CRONS

  cron { 'profile_backup verify':
    ensure  => $cron_ensure,
    command => "${work_directory}/cron_check_backup.sh",
    *       => $verify_cron_schedule,
  }

  cron { 'profile_backup backup jobs':
    ensure  => $cron_ensure,
    command => "${work_directory}/cron_do_backup.sh",
    *       => $job_cron_schedule,
  }
}
