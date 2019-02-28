# @summary validates bond config and writes it to $config_file via concat
#
# @api private
#
# @note intended to be used only by netplan class
#
#  Enable wake on LAN. Off by default.
# @param renderer
#  Use the given networking backend for this definition. Currently supported are networkd and NetworkManager.
#  This property can be specified globally in networks:, for a device type (in e. g. ethernets:) or for a
#  particular device definition. Default is networkd.
# @param dhcp4
#  Enable DHCP for IPv4. Off by default.
# @param dhcp6
#  Enable DHCP for IPv6. Off by default.
# @param dhcp_identifier
#  When set to ‘mac’; pass that setting over to systemd-networkd to use the device’s MAC address as a
#  unique identifier rather than a RFC4361-compliant Client ID. This has no effect when NetworkManager
#  is used as a renderer.
# @param accept_ra
#  Accept Router Advertisement that would have the kernel configure IPv6 by itself. On by default.
# @param addresses
#  Add static addresses to the interface in addition to the ones received through DHCP or RA.
#  Each sequence entry is in CIDR notation, i. e. of the form addr/prefixlen. addr is an IPv4 or IPv6
#  address as recognized by inet_pton(3) and prefixlen the number of bits of the subnet.
# @param gateway4
#  Set default gateway for IPv4, for manual address configuration. This requires setting addresses too.
# @param gateway6
#  Set default gateway for IPv6, for manual address configuration. This requires setting addresses too.
# @param nameservers
#  Set DNS servers and search domains, for manual address configuration. There are two supported fields:
#  addresses: is a list of IPv4 or IPv6 addresses similar to gateway*, and
#  search: is a list of search domains.
# @param macaddress
#  Set the device’s MAC address. The MAC address must be in the form "XX:XX:XX:XX:XX:XX".
# @param optional
#  An optional device is not required for booting. Normally, networkd will wait some time for device to
#  become configured before proceeding with booting. However, if a device is marked as optional, networkd
#  will not wait for it. This is only supported by networkd, and the default is false.
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
# @param routing_policy
#  The routing-policy block defines extra routing policy for a network, where traffic may be handled specially
#  based on the source IP, firewall marking, etc.
#  For from, to, both IPv4 and IPv6 addresses are recognized, and must be in the form addr/prefixlen or addr
#  from: Set a source IP address to match traffic for this policy rule.
#  to: Match on traffic going to the specified destination.
#  table: The table number to match for the route.
#  priority: Specify a priority for the routing policy rule, to influence the order in which routing rules are
#    processed. A higher number means lower priority: rules are processed in order by increasing priority number.
#  fwmark: Have this routing policy rule match on traffic that has been marked by the iptables firewall with
#    this value. Allowed values are positive integers starting from 1.
#  type_of_service: Match this policy rule based on the type of service number applied to the traffic.
# @param interfaces
#  All devices matching this ID list will be added to the bridge.
# @param parameters
#  Customization parameters for special bonding options. Using the NetworkManager renderer, parameter values 
#  for intervals should be expressed in milliseconds; for the systemd renderer, they should be in seconds 
#  unless otherwise specified.
#  mode: Set the bonding mode used for the interfaces. The default is balance-rr (round robin). Possible values 
#    are balance-rr, active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, and balance-alb.
#  lacp_rate: Set the rate at which LACPDUs are transmitted. This is only useful in 802.3ad mode. 
#    Possible values are slow (30 seconds, default), and fast (every second).
#  mii_monitor_interval: Specifies the interval for MII monitoring (verifying if an interface of the bond 
#    has carrier). The default is 0; which disables MII monitoring.
#  min_links: The minimum number of links up in a bond to consider the bond interface to be up.
#  transmit_hash_policy: Specifies the transmit hash policy for the selection of slaves. This is only 
#    useful in balance-xor, 802.3ad and balance-tlb modes. 
#    Possible values are layer2, layer3+4, layer2+3, encap2+3, and encap3+4.
#  ad_select: Set the aggregation selection mode. Possible values are stable, bandwidth, and count. This option 
#    is only used in 802.3ad mode.
#  all_slaves_active: If the bond should drop duplicate frames received on inactive ports, set this option to 
#    false. If they should be delivered, set this option to true. The default value is false, 
#    and is the desirable behavior in most situations.
#  arp_interval: Set the interval value for how frequently ARP link monitoring should happen. 
#    The default value is 0, which disables ARP monitoring.
#  arp_ip_targets: IPs of other hosts on the link which should be sent ARP requests in order to validate 
#    that a slave is up. This option is only used when arp-interval is set to a value other than 0. 
#    At least one IP address must be given for ARP link monitoring to function. Only IPv4 addresses are supported. 
#    You can specify up to 16 IP addresses. The default value is an empty list.
#  arp_validate: Configure how ARP replies are to be validated when using ARP link monitoring. 
#    Possible values are none, active, backup, and all.
#  arp_all_targets: Specify whether to use any ARP IP target being up as sufficient for a slave to be considered up; 
#    or if all the targets must be up. This is only used for active-backup mode when arp-validate is enabled. 
#    Possible values are any and all.
#  up_delay: Specify the delay before enabling a link once the link is physically up. The default value is 0.
#  down_delay: Specify the delay before disabling a link once the link has been lost. The default value is 0.
#  fail_over_mac_policy: Set whether to set all slaves to the same MAC address when adding them to the bond, 
#    or how else the system should handle MAC addresses. The possible values are none, active, and follow.
#  gratuitious_arp: Specify how many ARP packets to send after failover. Once a link is up on a new slave, 
#    a notification is sent and possibly repeated if this value is set to a number greater than 1. The default value 
#    is 1 and valid values are between 1 and 255. This only affects active-backup mode.
#  packets_per_slave: In balance-rr mode, specifies the number of packets to transmit on a slave before switching 
#    to the next. When this value is set to 0, slaves are chosen at random. Allowable values are between 0 and 65535. 
#    The default value is 1. This setting is only used in balance-rr mode.
#  primary_reselect_policy: Set the reselection policy for the primary slave. On failure of the active slave, the 
#    system will use this policy to decide how the new active slave will be chosen and how recovery will be handled. 
#    The possible values are always, better, and failure.
#  resend_igmp: In modes balance-rr, active-backup, balance-tlb and balance-alb, a failover can switch IGMP traffic 
#    from one slave to another.
#    This parameter specifies how many IGMP membership reports are issued on a failover event. Values range 
#    from 0 to 255. 0 disables sending membership reports. Otherwise, the first membership report is sent on 
#    failover and subsequent reports are sent at 200ms intervals.
#  learn_packet_interval: Specify the interval between sending learning packets to each slave. The value range is 
#    between 1 and 0x7fffffff. The default value is 1. This option only affects balance-tlb and balance-alb modes.
#  primary: Specify a device to be used as a primary slave, or preferred device to use as a slave for the bond 
#    (ie. the preferred device to send data through), whenever it is available. 
#    This only affects active-backup, balance-alb, and balance-tlb modes.
#
define netplan::bonds (

  # common properties
  Optional[Enum['networkd', 'NetworkManager']]                    $renderer = undef,
  #lint:ignore:quoted_booleans
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp4 = undef,
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp6 = undef,
  #lint:endignore
  Optional[Enum['mac']]                                           $dhcp_identifier = undef,
  Optional[Boolean]                                               $accept_ra = undef,
  Optional[Array[Stdlib::IP::Address]]                            $addresses = undef,
  Optional[Integer]                                               $mtu = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                     $gateway4 = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                     $gateway6 = undef,
  Optional[Struct[{
    'search'                    => Array[Stdlib::Fqdn],
    'addresses'                 => Array[Stdlib::IP::Address]
  }]]                                                             $nameservers = undef,
  Optional[Stdlib::MAC]                                           $macaddress = undef,
  Optional[Boolean]                                               $optional = undef,
  Optional[Array[Struct[{
    Optional['from']            => Stdlib::IP::Address,
    'to'                        => Variant[Stdlib::IP::Address, Enum['0.0.0.0/0', '::/0']],
    'via'                       => Stdlib::IP::Address::Nosubnet,
    Optional['on_link']         => Boolean,
    Optional['metric']          => Integer,
    Optional['type']            => Enum['unicast', 'unreachable', 'blackhole', 'prohibited'],
    Optional['scope']           => Enum['global', 'link', 'host'],
    Optional['table']           => Integer,
  }]]]                                                            $routes = undef,
  Optional[Array[Struct[{
    'from'                      => Stdlib::IP::Address,
    'to'                        => Variant[Stdlib::IP::Address, Enum['0.0.0.0/0', '::/0']],
    Optional['table']           => Integer,
    Optional['priority']        => Integer,
    Optional['fwmark']          => Integer,
    Optional['type_of_service'] => Integer,
  }]]]                                                            $routing_policy = undef,

  # bonds specific properties
  Array[String]                                                   $interfaces = undef,
  Optional[Struct[{
    Optional['mode']                    => Enum['balance-rr', 'active-backup', 'balance-xor',
                                                'broadcast', '802.3ad', 'balance-tlb', 'balance-alb'],
    Optional['lacp_rate']               => Enum['slow', 'fast'],
    Optional['mii_monitor_interval']    => Variant[Float, Integer],
    Optional['min_links']               => Integer,
    Optional['transmit_hash_policy']    => Enum['layer2', 'layer3+4', 'layer2+3', 'encap2+3', 'encap3+4'],
    Optional['ad_select']               => Enum['stable', 'bandwidth', 'count'],
    Optional['all_slaves_active']       => Boolean,
    Optional['arp_interval']            => Integer,
    Optional['arp_ip_targets']          => Array[Stdlib::IP::Address::V4::Nosubnet],
    Optional['arp_validate']            => Enum['none', 'active', 'backup', 'all'],
    Optional['arp_all_targets']         => Enum['any', 'all'],
    Optional['up_delay']                => Variant[Float, Integer],
    Optional['down_delay']              => Variant[Float, Integer],
    Optional['fail_over_mac_policy']    => Enum['none', 'active', 'follow'],
    Optional['gratuitious_arp']         => Integer,
    Optional['packets_per_slave']       => Integer,
    Optional['primary_reselect_policy'] => Enum['always', 'better', 'failure'],
    Optional['resend_igmp']             => Integer,
    Optional['learn_packet_interval']   => String,
    Optional['primary']                 => String,
  }]]                                                             $parameters = undef,

  ){

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

  $bondstmp = epp("${module_name}/bonds.epp", {
    'name'            => $name,
    'renderer'        => $renderer,
    'dhcp4'           => $_dhcp4,
    'dhcp6'           => $_dhcp6,
    'dhcp_identifier' => $dhcp_identifier,
    'accept_ra'       => $accept_ra,
    'addresses'       => $addresses,
    'mtu'             => $mtu,
    'gateway4'        => $gateway4,
    'gateway6'        => $gateway6,
    'nameservers'     => $nameservers,
    'macaddress'      => $macaddress,
    'optional'        => $optional,
    'routes'          => $routes,
    'routing_policy'  => $routing_policy,
    'interfaces'      => $interfaces,
    'parameters'      => $parameters,
  })

  concat::fragment { $name:
    target  => $netplan::config_file,
    content => $bondstmp,
    order   => '51',
  }

}
