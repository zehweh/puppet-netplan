# Changelog

## Release 2.0.0

#### Added
- all properties that are available in the latest netplan version 0.106.1
- device types: modem, vrf, dummy_device 

#### Changed
- BREAKING CHANGE: device type tunnel: `keys` is now an alias for `key`
- BREAKING CHANGE: device type bonds: 
  `all-slaves-active` has been renamed to `all-members-active`,
  `packets-per-slave` has been renamed to `packets-per-member`
- show deprecation info for `gateway4` and `gateway6`

## Release 1.0.1

#### Added
- support for new routing options: advertised-receive-window, congestion-window, mtu
- merged 'Gre tunnel fix' ([#25](https://github.com/zehweh/puppet-netplan/pull/25))
- merged 'Add from to routes to ethernets' ([#21](https://github.com/zehweh/puppet-netplan/pull/21))

## Release 1.0.0

#### Added
- support for device type `tunnels`
- support for authentication (wifi & ethernet)
- support for ipv6-privacy, link-local, dhcp4-overrides, dhcp6-overrides, optional-addresses

#### Fixed
- changed `fwmark` to `mark` in the `routing-policy` setting

## Release 0.1.10

#### Added
- merged 'Purges undeclared configuration file in /etc/netplan directory' ([PR #13](https://github.com/zehweh/puppet-netplan/pull/13))
- merged 'Add support for `critical` netplan option' ([PR #14](https://github.com/zehweh/puppet-netplan/pull/14))

## Release 0.1.9

#### Added
- merged 'Support puppet 6' ([PR #12](https://github.com/zehweh/puppet-netplan/pull/12))

## Release 0.1.8

#### Added
- merged 'add MTU support' ([PR #9](https://github.com/zehweh/puppet-netplan/pull/9))
- merged 'Add support for IPv6 default routes' ([PR #8](https://github.com/zehweh/puppet-netplan/pull/8))

## Release 0.1.7

#### Added
- updated dependencies

#### Fixed
- merged 'fix_logwatch_module_conflict' ([PR #7](https://github.com/zehweh/puppet-netplan/pull/7))

## Release 0.1.6

#### Fixed
- merged 'Expand $nameservers[addresses] to multi lines' ([PR #6](https://github.com/zehweh/puppet-netplan/pull/6))

## Release 0.1.5

#### Fixed
- puppetlabs-stdlib Stdlib::IP::Address::V4 doesn't match '0.0.0.0/0' ([Issue #5](https://github.com/zehweh/puppet-netplan/issues/5))

## Release 0.1.4

#### Fixed
- add absolute path to netplan binary ([Issue #4](https://github.com/zehweh/puppet-netplan/issues/4))

## Release 0.1.3

#### Fixed
- allow floats for mii_monitor_interval, up_delay, down_delay

## Release 0.1.2

#### Fixed
- fix puppet version requirement
- fix module name in metadata.json

#### Added
- remove appveyor.yml

## Release 0.1.1

#### Added
- migrate to PDK ([Issue #1](https://github.com/zehweh/puppet-netplan/issues/1))
- Changelog

#### Fixed
- fix lint issues with quoted boolean values
- fix typos

## Release 0.1.0

* Initial release
