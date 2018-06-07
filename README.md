# puppet-netplan

#### Table of Contents

1. [Description](#description)
1. [Requirements](#requirements)
1. [Usage](#usage)
1. [Limitations - OS compatibility](#limitations)
1. [Miscellaneous](#miscellaneous)

## Description

The netplan module manages and applies netplan configuration.

## Requirements

* Puppet >= 4.0
* puppetlabs/stdlib
* puppetlabs/concat


## Usage

### Example with include / Hiera

puppet code:
```
include netplan
```

Hiera yaml:
```
netplan::version: 2
netplan::renderer: networkd
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


 



## Limitations

This module was only tested on Ubuntu 18.04.


## Miscellaneous

The documentation of all parameters originates from the [Netplan Documentation](https://netplan.io/reference)
