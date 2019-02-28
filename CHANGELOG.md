# Changelog

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
