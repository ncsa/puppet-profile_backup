# @summary Defined type to add a new service backup job
#
# Add a service backup job to this backup client
#
# @param paths
#   List of directory paths for the job to backup.
#   Can be a list of directories and/or specific files.
#
# @param prehook_commands
#   Optional commands to run before backup job
#
# @param posthook_commands
#   Optional commands to run after the backup job
#
# @example
#   profile_backup::client::add_job { 'jobname':
#     paths             => [ '/directory1', '/tmp/directory2.tar', ],
#     prehook_commands  => 'tar cf /tmp/directory2.tar /directory2',
#     posthook_commands => 'rm -f /tmp/directory2.tar',
#   }
define profile_backup::client::add_job (
  Array[String] $paths,
  Optional[String] $prehook_commands = undef,
  Optional[String] $posthook_commands = undef,
) {
  $backup_paths = $paths.join(' ')
  $work_directory = $profile_backup::client::work_directory

  file { "${work_directory}/backup_job_${name}.sh":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('profile_backup/backup_job.sh.erb'),
    require => File[$profile_backup::client::work_directory],
  }
}
