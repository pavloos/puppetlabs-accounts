# @summary
#   This resource specifies where ssh keys are managed.
#
# @param group
#   Name of the users primary group.
#
# @param user
#   User that owns all of the files being created.
#
# @param user_home
#   Specifies the path to the user's home directory.
#
# @param sshkeys
#   List of ssh keys to be added for this user in this directory.
#
# @param sshkey_owner
#   Specifies the owner of the ssh key file.
#
# @param sshkey_custom_path
#   Path to custom file for ssh key management.
#
# @param sshkey_custom_path_mode
#   Specifies the mode of the sshkey file in custom location.
#
# @api private
#
define accounts::key_management(
  String $user,
  String $group,
  Optional[String] $user_home                 = undef,
  Array[String] $sshkeys                      = [],
  String $sshkey_owner                        = $user,
  Optional[String] $sshkey_custom_path        = undef,
  Pattern[/^\d{4}$/] $sshkey_custom_path_mode = '0600',
) {

  if $user_home {
    file { "${user_home}/.ssh":
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0700',
    }
  }

  if $sshkey_custom_path {
    $key_file = $sshkey_custom_path
    $key_mode = $sshkey_custom_path_mode
  } elsif $user_home {
    $key_file = "${user_home}/.ssh/authorized_keys"
    $key_mode = '0600'
  } else {
    err(translate('Either user_home or sshkey_custom_path must be specified'))
  }

  file { $key_file:
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => $key_mode,
    content => inline_template("<% @sshkeys.sort.each do |key| %><%= key %>\n<% end %>"),
  }

}
