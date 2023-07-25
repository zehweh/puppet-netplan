# @summary validates modem config and writes it to $config_file via concat
#
# @api private
#
# @note intended to be used only by netplan class
#
# Properties for physical device types
#
# @param match
#  This selects a subset of available physical devices by various hardware properties.
#  The following configuration will then apply to all matching devices, as soon as they appear.
#  All specified properties must match.
#  name: Current interface name. Globs are supported, and the primary use case for matching on names,
#    as selecting one fixed name can be more easily achieved with having no match: at all and just using
#    the ID (see above). Note that currently only networkd supports globbing, NetworkManager does not.
#  macaddress: Device’s MAC address in the form "XX:XX:XX:XX:XX:XX". Globs are not allowed.
#  driver: Kernel driver name, corresponding to the DRIVER udev property. Globs are supported.
#    Matching on driver is only supported with networkd.
# @param set_name
#  When matching on unique properties such as path or MAC, or with additional assumptions such as
#  "there will only ever be one wifi device", match rules can be written so that they only match one device.
#  Then this property can be used to give that device a more specific/desirable/nicer name than the default
#  from udev’s ifnames. Any additional device that satisfies the match rules will then fail to get renamed
#  and keep the original kernel name (and dmesg will show an error).
# @param wakeonlan
#  Enable wake on LAN. Off by default.
# @param emit_lldp 
#  (networkd backend only) Whether to emit LLDP packets. Off by default.
# @param receive_checksum_offload 
#  (networkd backend only) If set to true (false), the hardware offload for checksumming of ingress network 
#  packets is enabled (disabled). When unset, the kernel’s default will be used.
# @param transmit_checksum_offload 
#  (networkd backend only) If set to true (false), the hardware offload for checksumming of egress network 
#  packets is enabled (disabled). When unset, the kernel’s default will be used.
# @param tcp_segmentation_offload
#  (networkd backend only) If set to true (false), the TCP Segmentation Offload (TSO) is enabled (disabled). 
#  When unset, the kernel’s default will be used.
# @param tcp6_segmentation_offload
#  (networkd backend only) If set to true (false), the TCP6 Segmentation Offload (tx-tcp6-segmentation) is 
#  enabled (disabled). When unset, the kernel’s default will be used.
# @param generic_segmentation_offload
#  (networkd backend only) If set to true (false), the Generic Segmentation Offload (GSO) is 
#  enabled (disabled). When unset, the kernel’s default will be used.
# @param generic_receive_offload
#  (networkd backend only) If set to true (false), the Generic Receive Offload (GRO) is enabled (disabled). 
#  When unset, the kernel’s default will be used.
# @param large_receive_offload
#  (networkd backend only) If set to true (false), the Large Receive Offload (LRO) is enabled (disabled). 
#  When unset, the kernel’s default will be used.
# @param openvswitch
#  This provides additional configuration for the openvswitch network device. If Open vSwitch is not 
#  available on the system, netplan treats the presence of openvswitch configuration as an error.
#  external_ids: Passed-through directly to Open vSwitch
#  other_config: Passed-through directly to Open vSwitch
#  lacp: Valid for bond interfaces. Accepts active, passive or off (the default).
#  fail_mode: Valid for bridge interfaces. Accepts secure or standalone (the default).
#  mcast_snooping: Valid for bridge interfaces. False by default.
#  protocols: Valid for bridge interfaces or the network section. List of protocols to be used when negotiating 
#    a connection with the controller. Accepts OpenFlow10, OpenFlow11, OpenFlow12, OpenFlow13, OpenFlow14, 
#    and OpenFlow15.
#  rstp: Valid for bridge interfaces. False by default.
#  controller: Valid for bridge interfaces. Specify an external OpenFlow controller.
#    addresses: Set the list of addresses to use for the controller targets. The syntax of these addresses 
#      is as defined in ovs-vsctl(8). Example: addresses: [tcp:127.0.0.1:6653, "ssl:[fe80::1234%eth0]:6653"]
#    connection_mode: Set the connection mode for the controller. Supported options are in-band and 
#      out-of-band. The default is in-band.
#  ports: Open vSwitch patch ports. Each port is declared as a pair of names which can be referenced as 
#    interfaces in dependent virtual devices (bonds, bridges).
#  ssl: Valid for global openvswitch settings. Options for configuring SSL server endpoint for the switch.
#    ca_cert: Path to a file containing the CA certificate to be used.
#    certificate: Path to a file containing the server certificate.
#    private_key: Path to a file containing the private key for the server.
#
# Properties for all device types
#
# @param renderer
#  Use the given networking backend for this definition. Currently supported are networkd and NetworkManager.
#  This property can be specified globally in networks:, for a device type (in e. g. ethernets:) or for a
#  particular device definition. Default is networkd.
# @param dhcp4
#  Enable DHCP for IPv4. Off by default.
# @param dhcp6
#  Enable DHCP for IPv6. Off by default.
# @param ipv6_mtu
#  Set the IPv6 MTU (only supported with networkd backend). Note that needing to set this is an unusual 
#  requirement.
# @param ipv6_privacy
#  Enable IPv6 Privacy Extensions. Off by default.
# @param link_local
#  Configure the link-local addresses to bring up. Valid options are ‘ipv4’ and ‘ipv6’.
# @param ignore_carrier
#  (networkd backend only) Allow the specified interface to be configured even if it has no carrier.
# @param critical
#  (networkd backend only) Designate the connection as "critical to the system", meaning that special
#  care will be taken by systemd-networkd to not release the IP from DHCP when the daemon is restarted.
# @param dhcp_identifier
#  When set to ‘mac’; pass that setting over to systemd-networkd to use the device’s MAC address as a
#  unique identifier rather than a RFC4361-compliant Client ID. This has no effect when NetworkManager
#  is used as a renderer.
# @param dhcp4_overrides
#  (networkd backend only) Overrides default DHCP behavior
#  use_dns: Default: true. When true, the DNS servers received from the DHCP server will be used and 
#    take precedence over any statically configured ones. Currently only has an effect on the 
#    networkd backend.
#  use_ntp: Default: true. When true, the NTP servers received from the DHCP server will be used 
#    by systemd-timesyncd and take precedence over any statically configured ones. Currently only 
#    has an effect on the networkd backend.
#  send_hostname: Default: true. When true, the machine’s hostname will be sent to the DHCP server. 
#    Currently only has an effect on the networkd backend.
#  use_hostname: Default: true. When true, the hostname received from the DHCP server will be set as
#    the transient hostname of the system. Currently only has an effect on the networkd backend.
#  use_mtu: Default: true. When true, the MTU received from the DHCP server will be set as the MTU 
#    of the network interface. When false, the MTU advertised by the DHCP server will be ignored. 
#    Currently only has an effect on the networkd backend.
#  hostname: Use this value for the hostname which is sent to the DHCP server, instead of machine’s 
#    hostname. Currently only has an effect on the networkd backend.
#  use_routes: Default: true. When true, the routes received from the DHCP server will be installed 
#    in the routing table normally. When set to false, routes from the DHCP server will be ignored: 
#    in this case, the user is responsible for adding static routes if necessary for correct network 
#    operation. This allows users to avoid installing a default gateway for interfaces configured via 
#    DHCP. Available for both the networkd and NetworkManager backends.
#  route_metric: Use this value for default metric for automatically-added routes. Use this to prioritize 
#    routes for devices by setting a lower metric on a preferred interface. Available for both the 
#    networkd and NetworkManager backends.
#  use_domains: Takes a boolean, or the special value “route”. When true, the domain name received from 
#    the DHCP server will be used as DNS search domain over this link, similar to the effect of the 
#    Domains= setting. If set to “route”, the domain name received from the DHCP server will be used for 
#    routing DNS queries only, but not for searching, similar to the effect of the Domains= setting when 
#    the argument is prefixed with “~”.
# @param dhcp6_overrides
#  (networkd backend only) Overrides default DHCP behavior
#  use_dns: Default: true. When true, the DNS servers received from the DHCP server will be used and 
#    take precedence over any statically configured ones. Currently only has an effect on the 
#    networkd backend.
#  use_ntp: Default: true. When true, the NTP servers received from the DHCP server will be used 
#    by systemd-timesyncd and take precedence over any statically configured ones. Currently only 
#    has an effect on the networkd backend.
#  send_hostname: Default: true. When true, the machine’s hostname will be sent to the DHCP server. 
#    Currently only has an effect on the networkd backend.
#  use_hostname: Default: true. When true, the hostname received from the DHCP server will be set as
#    the transient hostname of the system. Currently only has an effect on the networkd backend.
#  use_mtu: Default: true. When true, the MTU received from the DHCP server will be set as the MTU 
#    of the network interface. When false, the MTU advertised by the DHCP server will be ignored. 
#    Currently only has an effect on the networkd backend.
#  hostname: Use this value for the hostname which is sent to the DHCP server, instead of machine’s 
#    hostname. Currently only has an effect on the networkd backend.
#  use_routes: Default: true. When true, the routes received from the DHCP server will be installed 
#    in the routing table normally. When set to false, routes from the DHCP server will be ignored: 
#    in this case, the user is responsible for adding static routes if necessary for correct network 
#    operation. This allows users to avoid installing a default gateway for interfaces configured via 
#    DHCP. Available for both the networkd and NetworkManager backends.
#  route_metric: Use this value for default metric for automatically-added routes. Use this to prioritize 
#    routes for devices by setting a lower metric on a preferred interface. Available for both the 
#    networkd and NetworkManager backends.
#  use_domains: Takes a boolean, or the special value “route”. When true, the domain name received from 
#    the DHCP server will be used as DNS search domain over this link, similar to the effect of the 
#    Domains= setting. If set to “route”, the domain name received from the DHCP server will be used for 
#    routing DNS queries only, but not for searching, similar to the effect of the Domains= setting when 
#    the argument is prefixed with “~”.
# @param accept_ra
#  Accept Router Advertisement that would have the kernel configure IPv6 by itself. On by default.
# @param addresses
#  Add static addresses to the interface in addition to the ones received through DHCP or RA.
#  Each sequence entry is in CIDR notation, i. e. of the form addr/prefixlen. addr is an IPv4 or IPv6
#  address as recognized by inet_pton(3) and prefixlen the number of bits of the subnet.
#  lifetime: Default: forever. This can be forever or 0 and corresponds to the PreferredLifetime option 
#    in systemd-networkd’s Address section. Currently supported on the networkd backend only.
#  label: An IP address label, equivalent to the ip address label command. Currently supported on the 
#    networkd backend only.
# @param ipv6_address_generation
#  Configure method for creating the address for use with RFC4862 IPv6 Stateless Address Auto-configuration 
#  (only supported with NetworkManager backend). Possible values are eui64 or stable-privacy.
# @param ipv6_address_token
#  Define an IPv6 address token for creating a static interface identifier for IPv6 Stateless Address 
#  Auto-configuration. This is mutually exclusive with ipv6-address-generation.
# @param gateway4
#  Deprecated, see Default routes. Set default gateway for IPv4, for manual address configuration. 
#  This requires setting addresses too.
# @param gateway6
#  Deprecated, see Default routes. Set default gateway for IPv6, for manual address configuration. 
#  This requires setting addresses too.
# @param nameservers
#  Set DNS servers and search domains, for manual address configuration. There are two supported fields:
#  addresses: is a list of IPv4 or IPv6 addresses similar to gateway*, and
#  search: is a list of search domains.
# @param macaddress
#  Set the device’s MAC address. The MAC address must be in the form "XX:XX:XX:XX:XX:XX".
# @param mtu
#  Set the Maximum Transmission Unit for the interface. The default is 1500. Valid values depend on your 
#  network interface.
# @param optional
#  An optional device is not required for booting. Normally, networkd will wait some time for device to
#  become configured before proceeding with booting. However, if a device is marked as optional, networkd
#  will not wait for it. This is only supported by networkd, and the default is false.
# @param optional_addresses
#  Specify types of addresses that are not required for a device to be considered online.
# @param activation_mode
#  Allows specifying the management policy of the selected interface. By default, netplan brings up any 
#  configured interface if possible. Using the activation-mode setting users can override that behavior by 
#  either specifying manual, to hand over control over the interface state to the administrator or (for 
#  networkd backend only) off to force the link in a down state at all times. Any interface with 
#  activation-mode defined is implicitly considered optional. Supported officially as of networkd v248+. 
# @param routes
#  Configure static routing for the device.
#  from: Set a source IP address for traffic going through the route.
#  to: Destination address for the route.
#  via: Address to the gateway to use for this route.
#  on-link: When set to "true", specifies that the route is directly connected to the interface.
#  metric: The relative priority of the route. Must be a positive integer value.
#  type: The type of route. Valid options are “unicast" (default), “unreachable", “blackhole" or “prohibited".
#  scope: The route scope, how wide-ranging it is to the network. Possible values are “global", “link", or “host".
#  table: The table number to use for the route.
#  mtu: The MTU to be used for the route, in bytes. Must be a positive integer value.
#  congestion-window: The congestion window to be used for the route, represented by number of segments. Must 
#    be a positive integer value.
#  advertised-receive-window: The receive window to be advertised for the route, represented by number of segments. 
#    Must be a positive integer value.
# @param routing_policy
#  The routing-policy block defines extra routing policy for a network, where traffic may be handled specially
#  based on the source IP, firewall marking, etc.
#  For from, to, both IPv4 and IPv6 addresses are recognized, and must be in the form addr/prefixlen or addr
#  from: Set a source IP address to match traffic for this policy rule.
#  to: Match on traffic going to the specified destination.
#  table: The table number to match for the route.
#  priority: Specify a priority for the routing policy rule, to influence the order in which routing rules are
#    processed. A higher number means lower priority: rules are processed in order by increasing priority number.
#  mark: Have this routing policy rule match on traffic that has been marked by the iptables firewall with
#    this value. Allowed values are positive integers starting from 1.
#  type_of_service: Match this policy rule based on the type of service number applied to the traffic.
# @param neigh_suppress
#  Takes a boolean. Configures whether ARP and ND neighbor suppression is enabled for this port. When unset, the 
#  kernel’s default will be used.
#
# Properties for device type modems
#
# @param apn
#  Set the carrier APN (Access Point Name). This can be omitted if auto-config is enabled.
# @param auto_config
#  Specify whether to try and auto-configure the modem by doing a lookup of the carrier against 
#  the Mobile Broadband Provider database. This may not work for all carriers.
# @param device_id
#  Specify the device ID (as given by the WWAN management service) of the modem to match. 
#  This can be found using mmcli.
# @param network_id
#  Specify the Network ID (GSM LAI format). If this is specified, the device will not roam networks.
# @param number
#  The number to dial to establish the connection to the mobile broadband network. (Deprecated for GSM)
# @param password
#  Specify the password used to authenticate with the carrier network. 
#  This can be omitted if auto-config is enabled.
# @param pin
#  Specify the SIM PIN to allow it to operate if a PIN is set.
# @param sim_id
#  Specify the SIM unique identifier (as given by the WWAN management service) which this connection 
#  applies to. If given, the connection will apply to any device also allowed by device-id which contains 
#  a SIM card matching the given identifier.
# @param sim_operator_id
#  Specify the MCC/MNC string (such as “310260” or “21601”) which identifies the carrier that this connection 
#  should apply to. If given, the connection will apply to any device also allowed by device-id and sim-id 
#  which contains a SIM card provisioned by the given operator.
# @param username
#  Specify the username used to authenticate with the carrier network. This can be omitted if auto-config 
#  is enabled.
#
define netplan::modems (

  # Properties for physical device types
  Optional[Struct[{
        Optional['name']             => String,
        Optional['macaddress']       => Stdlib::MAC,
        Optional['driver']           => String,
  }]]                                                             $match = undef,
  Optional[String]                                                $set_name = undef,
  Optional[Boolean]                                               $wakeonlan = undef,
  Optional[Boolean]                                               $emit_lldp = undef,
  Optional[Boolean]                                               $receive_checksum_offload = undef,
  Optional[Boolean]                                               $transmit_checksum_offload = undef,
  Optional[Boolean]                                               $tcp_segmentation_offload = undef,
  Optional[Boolean]                                               $tcp6_segmentation_offload = undef,
  Optional[Boolean]                                               $generic_segmentation_offload = undef,
  Optional[Boolean]                                               $generic_receive_offload = undef,
  Optional[Boolean]                                               $large_receive_offload = undef,
  Optional[Struct[{
        Optional['external_ids']     => String,
        Optional['other_config']     => String,
        Optional['lacp']             => Enum['active', 'passive', 'off'],
        Optional['fail_mode']        => Enum['secure', 'standalone', 'off'],
        Optional['mcast_snooping']   => Boolean,
        Optional['protocols']        => Array[String],
        Optional['rstp']             => Boolean,
        Optional['controller']       => Struct[{
            Optional['addresses']           => Array[String],
            Optional['connection_mode']     => Enum['in-band', 'out-of-band'],
        }],
        Optional['ports']            => Array[Array[String]],
        Optional['ssl']              => Struct[{
            Optional['ca_cert']             => String,
            Optional['certificate']         => String,
            Optional['private_key']         => String,
        }],
  }]]                                                             $openvswitch = undef,

  # Properties for all device types
  Optional[Enum['NetworkManager']]                                $renderer = undef,
  #lint:ignore:quoted_booleans
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp4 = undef,
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp6 = undef,
  #lint:endignore
  Optional[Integer]                                               $ipv6_mtu = undef,
  Optional[Boolean]                                               $ipv6_privacy = undef,
  Optional[Tuple[Enum['ipv4', 'ipv6'], 0]]                        $link_local = undef,
  Optional[Boolean]                                               $ignore_carrier = undef,
  Optional[Boolean]                                               $critical = undef,
  Optional[Enum['mac']]                                           $dhcp_identifier = undef,
  Optional[Struct[{
        Optional['use_dns']         => Boolean,
        Optional['use_ntp']         => Boolean,
        Optional['send_hostname']   => Boolean,
        Optional['use_hostname']    => Boolean,
        Optional['use_mtu']         => Boolean,
        Optional['hostname']        => Stdlib::Fqdn,
        Optional['use_routes']      => Boolean,
        Optional['route_metric']    => Integer,
        Optional['use_domains']     => Variant[Enum['route', 'true', 'false', 'yes', 'no'], Boolean],
  }]]                                                             $dhcp4_overrides = undef,
  Optional[Struct[{
        Optional['use_dns']         => Boolean,
        Optional['use_ntp']         => Boolean,
        Optional['send_hostname']   => Boolean,
        Optional['use_hostname']    => Boolean,
        Optional['use_mtu']         => Boolean,
        Optional['hostname']        => Stdlib::Fqdn,
        Optional['use_routes']      => Boolean,
        Optional['route_metric']    => Integer,
        Optional['use_domains']     => Variant[Enum['route', 'true', 'false', 'yes', 'no'], Boolean],
  }]]                                                             $dhcp6_overrides = undef,
  Optional[Boolean]                                               $accept_ra = undef,
  Optional[Array[Variant[
      Stdlib::IP::Address,
      Hash[
            Stdlib::IP::Address,
            Struct[{
                  Optional['lifetime'] => Variant[Enum['forever'], Integer[0,0]],
                  Optional['label']    => String[1]
            }]
      ]
  ]]]                                                             $addresses = undef,
  Optional[Enum['eui64', 'stable-privacy']]                       $ipv6_address_generation = undef,
  Optional[String]                                                $ipv6_address_token = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                     $gateway4 = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                     $gateway6 = undef,
  Optional[Struct[{
        Optional['search']          => Array[Stdlib::Fqdn],
        'addresses'                 => Array[Stdlib::IP::Address]
  }]]                                                             $nameservers = undef,
  Optional[Stdlib::MAC]                                           $macaddress = undef,
  Optional[Integer]                                               $mtu = undef,
  Optional[Boolean]                                               $optional = undef,
  Optional[Array[String]]                                         $optional_addresses = undef,
  Optional[Enum['manual', 'off']]                                 $activation_mode = undef,
  Optional[Array[Struct[{
          Optional['from']                      => Stdlib::IP::Address,
          'to'                                  => Variant[Stdlib::IP::Address, Enum['default', '0.0.0.0/0', '::/0']],
          Optional['via']                       => Stdlib::IP::Address::Nosubnet,
          Optional['on_link']                   => Boolean,
          Optional['metric']                    => Integer,
          Optional['type']                      => Enum['unicast', 'unreachable', 'blackhole', 'prohibited'],
          Optional['scope']                     => Enum['global', 'link', 'host'],
          Optional['table']                     => Integer,
          Optional['mtu']                       => Integer,
          Optional['congestion_window']         => Integer,
          Optional['advertised_receive_window'] => Integer,
  }]]]                                                            $routes = undef,
  Optional[Array[Struct[{
          'from'                      => Stdlib::IP::Address,
          'to'                        => Variant[Stdlib::IP::Address, Enum['default', '0.0.0.0/0', '::/0']],
          Optional['table']           => Integer,
          Optional['priority']        => Integer,
          Optional['mark']            => Integer,
          Optional['type_of_service'] => Integer,
  }]]]                                                            $routing_policy = undef,
  Optional[Boolean]                                               $neigh_suppress = undef,

  # Properties for device type modems
  Optional[String]                                                $apn = undef,
  Optional[Boolean]                                               $auto_config = undef,
  Optional[String]                                                $device_id = undef,
  Optional[Integer]                                               $network_id = undef,
  Optional[String]                                                $number = undef,
  Optional[String]                                                $password = undef,
  Optional[Integer]                                               $pin = undef,
  Optional[String]                                                $sim_id = undef,
  Optional[Integer]                                               $sim_operator_id = undef,
  Optional[String]                                                $username = undef,

) {
  $_dhcp4 = $dhcp4 ? {
    true    => true,
    'yes'   => true,
    false   => false,
    'no'    => false,
    default => undef,
  }

  $_dhcp6 = $dhcp6 ? {
    true    => true,
    'yes'   => true,
    false   => false,
    'no'    => false,
    default => undef,
  }

  # show deprecation infos for gateway4 & gateway6
  if $gateway4 != undef {
      notify {"puppet-netplan modems ${name}: gateway4 has been deprecated, use default routes instead.": }
  }
  if $gateway6 != undef {
      notify {"puppet-netplan modems ${name}: gateway6 has been deprecated, use default routes instead.": }
  }

  $modemstmp = epp("${module_name}/modems.epp", {
      'name'                           => $name,
      'match'                          => $match,
      'set_name'                       => $set_name,
      'wakeonlan'                      => $wakeonlan,
      'emit_lldp'                      => $emit_lldp,
      'receive_checksum_offload'       => $receive_checksum_offload,
      'transmit_checksum_offload'      => $transmit_checksum_offload,
      'tcp_segmentation_offload'       => $tcp_segmentation_offload,
      'tcp6_segmentation_offload'      => $tcp6_segmentation_offload,
      'generic_segmentation_offload'   => $generic_segmentation_offload,
      'generic_receive_offload'        => $generic_receive_offload,
      'large_receive_offload'          => $large_receive_offload,
      'openvswitch'                    => $openvswitch,
      'renderer'                       => $renderer,
      'dhcp4'                          => $_dhcp4,
      'dhcp6'                          => $_dhcp6,
      'ipv6_mtu'                       => $ipv6_mtu,
      'ipv6_privacy'                   => $ipv6_privacy,
      'link_local'                     => $link_local,
      'ignore_carrier'                 => $ignore_carrier,
      'critical'                       => $critical,
      'dhcp_identifier'                => $dhcp_identifier,
      'dhcp4_overrides'                => $dhcp4_overrides,
      'dhcp6_overrides'                => $dhcp6_overrides,
      'accept_ra'                      => $accept_ra,
      'addresses'                      => $addresses,
      'ipv6_address_generation'        => $ipv6_address_generation,
      'gateway4'                       => $gateway4,
      'gateway6'                       => $gateway6,
      'nameservers'                    => $nameservers,
      'macaddress'                     => $macaddress,
      'mtu'                            => $mtu,
      'optional'                       => $optional,
      'optional_addresses'             => $optional_addresses,
      'activation_mode'                => $activation_mode,
      'routes'                         => $routes,
      'routing_policy'                 => $routing_policy,
      'neigh_suppress'                 => $neigh_suppress,
      'apn'                            => $apn,
      'auto_config'                    => $auto_config,
      'device_id'                      => $device_id,
      'network_id'                     => $network_id,
      'number'                         => $number,
      'password'                       => $password,
      'pin'                            => $pin,
      'sim_id'                         => $sim_id,
      'sim_operator_id'                => $sim_operator_id,
      'username'                       => $username,
  })

  concat::fragment { $name:
    target  => $netplan::config_file,
    content => $modemstmp,
    order   => '81',
  }
}
