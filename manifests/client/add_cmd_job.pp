# @summary Defined type to add a new service backup job
#
# Add a service backup job to this backup client
#
# @param backup_command
#   List of directory paths for the job to backup.
#   Can be a list of directories and/or specific files.
#
# @param filename
#   Name of the file created by the command located 
#   within the archive.
#
# @param prehook_commands
#   Optional list of commands to run before backup job
#
# @param posthook_commands
#   Optional list of commands to run after the backup job
#
# @example
#   profile_backup::client::add_job { 'jobname':
#     paths             => [ '/directory1', '/tmp/directory2.tar', ],
#     prehook_commands  => [ 'tar cf /tmp/directory2.tar /directory2', ],
#     posthook_commands => [ 'rm -f /tmp/directory2.tar', ],
#   }
define profile_backup::client::add_cmd_job (
  String $backup_command,
  String $filename,
  Optional[Array[String]] $prehook_commands = undef,
  Optional[Array[String]] $posthook_commands = undef,
) {
  $work_directory = $profile_backup::client::work_directory
  $sanitizedname = regsubst($name,'[\-]','_','G')
  file { "${work_directory}/backup_job_${sanitizedname}.sh":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('profile_backup/backup_cmd_job.sh.erb'),
    require => File[$profile_backup::client::work_directory],
  }
}
