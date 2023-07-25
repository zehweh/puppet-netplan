# @summary manages and applies netplan configuration
#
# @api public
#
# @param ethernets
#  hash with ethernet configuration (see ethernets.pp)
# @param vlans
#  hash with vlan configuration (see vlans.pp)
# @param wifis
#  hash with wifi configuration (see wifis.pp)
# @param bridges
#  hash with bridges configuration (see bridges.pp)
# @param bonds
#  hash with bonds configuration (see bonds.pp)
# @param tunnels
#  hash with tunnels configuration (see tunnels.pp)
# @param dummy_devices
#  hash with dummy_devices configuration (see dummy_devices.pp)
# @param modems
#  hash with modems configuration (see modems.pp)
# @param vrfs
#  hash with vrfs configuration (see vrfs.pp)
# @param config_file
#  absolute path to netplan config file
# @param config_file_mode
#  file permissions for netplan config file
# @param renderer
#  network renderer - can be one of 'networkd' and 'NetworkManager'
# @param version
#  netplan config file version
# @param netplan_apply
#  whether or not to apply the changes
# @param purge_config
#  whether or not to purge the netplan directory
#
class netplan (
  Optional[Hash]       $ethernets = undef,
  Optional[Hash]       $vlans = undef,
  Optional[Hash]       $wifis = undef,
  Optional[Hash]       $bridges = undef,
  Optional[Hash]       $bonds = undef,
  Optional[Hash]       $tunnels = undef,
  Optional[Hash]       $dummy_devices = undef,
  Optional[Hash]       $modems = undef,
  Optional[Hash]       $vrfs = undef,
  Stdlib::Absolutepath $config_file = '/etc/netplan/01-netcfg.yaml',
  String               $config_file_mode = '0600',
  String               $renderer = 'networkd',
  Integer              $version = 2,
  Boolean              $netplan_apply = true,
  Boolean              $purge_config = true,
  ){

  file { '/etc/netplan':
    ensure => directory,
  }

  if $purge_config {
    File['/etc/netplan'] {
      purge   => true,
      recurse => true,
      force   => true,
    }
  }

  $notify = $netplan_apply ? {
    true    => Exec['netplan_apply'],
    default => undef,
  }

  exec { 'netplan_apply':
    command     => '/usr/sbin/netplan apply',
    logoutput   => 'on_failure',
    refreshonly => true,
  }

  concat { $netplan::config_file:
    ensure => present,
    mode   => $config_file_mode,
    notify => $notify,
  }

  $headertmp = epp("${module_name}/header.epp", {
    'version'   => $version,
    'renderer'  => $renderer,
  })

  concat::fragment { 'netplan_header':
    target  => $netplan::config_file,
    content => $headertmp,
    order   => '01',
  }

  if $ethernets {
    concat::fragment { 'ethernets_header':
      target  => $netplan::config_file,
      content => "  ethernets:\n",
      order   => '10',
    }
    create_resources(netplan::ethernets, $ethernets)
  }

  if $vlans {
    concat::fragment { 'vlans_header':
      target  => $netplan::config_file,
      content => "  vlans:\n",
      order   => '20',
    }
    create_resources(netplan::vlans, $vlans)
  }

  if $wifis {
    concat::fragment { 'wifis_header':
      target  => $netplan::config_file,
      content => "  wifis:\n",
      order   => '30',
    }
    create_resources(netplan::wifis, $wifis)
  }

  if $bridges {
    concat::fragment { 'bridges_header':
      target  => $netplan::config_file,
      content => "  bridges:\n",
      order   => '40',
    }
    create_resources(netplan::bridges, $bridges)
  }

  if $bonds {
    concat::fragment { 'bonds_header':
      target  => $netplan::config_file,
      content => "  bonds:\n",
      order   => '50',
    }
    create_resources(netplan::bonds, $bonds)
  }

  if $tunnels {
    concat::fragment { 'tunnels_header':
      target  => $netplan::config_file,
      content => "  tunnels:\n",
      order   => '60',
    }
    create_resources(netplan::tunnels, $tunnels)
  }

  if $dummy_devices {
    concat::fragment { 'dummy_devices_header':
      target  => $netplan::config_file,
      content => "  dummy-devices:\n",
      order   => '70',
    }
    create_resources(netplan::dummy_devices, $dummy_devices)
  }

  if $modems {
    concat::fragment { 'modems_header':
      target  => $netplan::config_file,
      content => "  modems:\n",
      order   => '80',
    }
    create_resources(netplan::modems, $modems)
  }

  if $vrfs {
    concat::fragment { 'vrfs_header':
      target  => $netplan::config_file,
      content => "  vrfs:\n",
      order   => '90',
    }
    create_resources(netplan::vrfs, $vrfs)
  }
}
