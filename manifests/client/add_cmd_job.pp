# @summary Defined type to add a new service backup cmd job
#
# Add a service cmd backup job to this backup client
# This allows the streaming of data (STDOUT) directly to
# the backup without staging data to a file first. An example
# for the use would be to eliminate the need for a large database
# to be stored locally before being backed up.
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
# 
# This will dump the database to mydatabase.dump with the backup job name 
# jobname. No space will be consumed on the localhost and the STDOUT of 
# the mysqldump will be written to a file. 
#
#   profile_backup::client::add_cmd_job { 'jobname':
#     backup_command    => 'mysqldump --single-transaction --all-databases',
#     filename          => 'mydatabase.dump',
#   }
#

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
