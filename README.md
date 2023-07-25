# puppet-netplan

#### Table of Contents

1. [Description](#description)
1. [Requirements](#requirements)
1. [Usage](#usage)
1. [Open vSwitch](#open-vswitch)
1. [Miscellaneous](#miscellaneous)

## Description

The netplan module manages and applies netplan configuration.

## Requirements

* Puppet >= 4.0
* puppetlabs/stdlib
* puppetlabs/concat


## Usage

### Example with include / Hiera

To use the module with Hiera, you can include the netplan class in your Puppet code:
```
include netplan
```

Then, define the netplan configuration in your Hiera YAML file:
```
netplan::version: 2
netplan::renderer: networkd
netplan::purge_config: true
netplan::ethernets:
    eno1:
      dhcp4: yes
      addresses:
        - 192.168.0.125/16
      nameservers:
        search: [foo.local, bar.local]
        addresses: [8.8.8.8, 4.4.4.4]
      routes:
        - to: 10.10.0.1/16
          via: 10.20.0.1
```


### Example using class

Alternatively, you can use the netplan class directly in your Puppet code:
```
  class { 'netplan':
    config_file   => '/etc/netplan/01-custom.yaml',
    ethernets     => {
      'ens5' => {
        'dhcp4' => false
      }
    },
    bridges       => {
       'br0' => {
          'dhcp4' => true,
          'interfaces' => [ens5]
       }
    },
    netplan_apply => true,
  }
```

## Open vSwitch

The `external_ids` and `other_config` settings in the openvswitch property allow you to pass arbitrary configurations directly to Open vSwitch. To achieve this, you must use the configuration as a string and pay attention to proper indentation.

### Example:

Suppose you want to configure Open vSwitch as follows:
```
    ens13:
      openvswitch:
        external-ids:
          iface-id: mylocaliface
        other-config:
          disable-in-band: false
```

To pass this configuration as a string in your Hiera file, follow this format:
``` 
    ens13:
      openvswitch:
        external_ids: |-1
                   iface-id: mylocaliface
        other_config: |-1
                   disable-in-band: false
```
Ensure that you maintain the correct indentation while providing the configuration as a string to ensure proper parsing by netplan.

## Miscellaneous

For detailed information about each parameter, refer to the [Netplan Documentation](https://netplan.io/reference). The documentation for this module is based on the Netplan official reference.