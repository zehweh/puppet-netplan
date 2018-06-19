# @summary applies netplan configuration
#
# @example
#   include netplan::apply
class netplan::apply {

  exec { 'netplan_apply':
    command     => '/usr/sbin/netplan apply',
    logoutput   => 'on_failure',
    refreshonly => true,
  }

}
