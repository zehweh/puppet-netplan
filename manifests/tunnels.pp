# @summary validates tunnel config and writes it to $config_file via concat
#
# @api private
#
# @note intended to be used only by netplan class
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
# Properties for device type tunnels
#
# @param mode
#  Defines the tunnel mode. Valid options are sit, gre, ip6gre, ipip, ipip6, ip6ip6, vti, and vti6. Additionally,
#  the networkd backend also supports gretap and ip6gretap modes. In addition, the NetworkManager backend supports
#  isatap tunnels.
# @param local
#  Defines the address of the local endpoint of the tunnel.
# @param remote
#  Defines the address of the remote endpoint of the tunnel.
# @param ttl
#  Defines the ttl of the tunnel.
# @param key
#  Define keys to use for the tunnel. The key can be a number or a dotted quad (an IPv4 address). It is used for
#  identification of IP transforms. This is only required for vti and vti6 when using the networkd backend, and
#  for gre or ip6gre tunnels when using the NetworkManager backend.
# @param keys
#  You can further specify input and output:
#  input: The input key for the tunnel
#  output: The output key for the tunnel
#  private: A base64-encoded private key required for WireGuard tunnels. When the systemd-networkd backend (v242+) 
#    is used, this can also be an absolute path to a file containing the private key.
# Wiregard specific keys
# @param mark
#   Firewall mark for outgoing WireGuard packets from this interface, optional.
# @param port
#   UDP port to listen at or auto. Optional, defaults to auto.
# @param peers
#   A list of peers, see netplan documentation
#   endpoint: Remote endpoint IPv4/IPv6 address or a hostname, followed by a colon and a port number.
#   allowed_ips: A list of IP (v4 or v6) addresses with CIDR masks from which this peer is allowed to 
#     send incoming traffic and to which outgoing traffic for this peer is directed. The catch-all 0.0.0.0/0 may 
#     be specified for matching all IPv4 addresses, and ::/0 may be specified for matching all IPv6 addresses. 
#   keepalive: An interval in seconds, between 1 and 65535 inclusive, of how often to send an authenticated 
#     empty packet to the peer for the purpose of keeping a stateful firewall or NAT mapping valid persistently.
#   keys: Define keys to use for the WireGuard peers. This field can be used as a mapping, where you can further 
#     specify the public and shared keys.
#     public: A base64-encoded public key, required for WireGuard peers.
#     shared: A base64-encoded preshared key. Optional for WireGuard peers. When the systemd-networkd backend 
#       (v242+) is used, this can also be an absolute path to a file containing the preshared key.
# VXLAN specific keys
# @param id
#   The VXLAN Network Identifier (VNI or VXLAN Segment ID). Takes a number in the range 1..16777215.
# @param link
#   netplan ID of the parent device definition to which this VXLAN gets connected.
# @param type_of_service
#   The Type Of Service byte value for a vxlan interface.
# @param mac_learning
#   Takes a boolean. When true, enables dynamic MAC learning to discover remote MAC addresses.
# @param ageing
#   The lifetime of Forwarding Database entry learned by the kernel, in seconds.
# @param limit
#   Configures maximum number of FDB entries.
# @param arp_proxy
#   Takes a boolean. When true, bridge-connected VXLAN tunnel endpoint answers ARP requests from the local bridge 
#   on behalf of remote Distributed Overlay Virtual Ethernet (DOVE) clients. Defaults to false.
# @param notifications
#   Takes the flags l2-miss and l3-miss to enable netlink LLADDR and/or netlink IP address miss notifications.
# @param short_circuit
#   Takes a boolean. When true, route short circuiting is turned on.
# @param checksums
#   Takes the flags udp, zero-udp6-tx, zero-udp6-rx, remote-tx and remote-rx to enable transmitting UDP 
#   checksums in VXLAN/IPv4, send/receive zero checksums in VXLAN/IPv6 and enable sending/receiving checksum 
#   offloading in VXLAN.
# @param extensions
#   Takes the flags group-policy and generic-protocol to enable the “Group Policy” and/or “Generic Protocol” VXLAN extensions.
# @oaram port
#   Configures the default destination UDP port. If the destination port is not specified then Linux kernel default will be 
#   used. Set to 4789 to get the IANA assigned value.
# @param port_range
#   Configures the source port range for the VXLAN. The kernel assigns the source UDP port based on the flow to help the 
#   receiver to do load balancing. When this option is not set, the normal range of local UDP ports is used. Uses the 
#   form [LOWER, UPPER].
# @param flow_label
#   Specifies the flow label to use in outgoing packets. The valid range is 0-1048575.
# @param do_not_fragment
#   Allows setting the IPv4 Do not Fragment (DF) bit in outgoing packets. Takes a boolean value. When unset, 
#   the kernel’s default will be used.
define netplan::tunnels (

  # Properties for all device types
  Optional[Enum['networkd', 'NetworkManager']]                    $renderer = undef,
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

  # Properties for device type tunnels
  Enum['sit', 'gre', 'ip6gre', 'ipip', 'ipip6', 'ip6ip6', 'vti', 'vti6',
          'wireguard', 'vxlan', 'gretap', 'ip6gretap', 'isatap']  $mode = undef,
  Optional[Stdlib::IP::Address::Nosubnet]                         $local = undef,
  Optional[Stdlib::IP::Address::Nosubnet]                         $remote = undef,
  Optional[Integer[1,255]]                                        $ttl = undef,
  Optional[Variant[Scalar, Struct[{
          Optional['input']           => Integer,
          Optional['output']          => Integer,
          Optional['private']         => String,
  }]]]                                                            $key = undef,

  # Wireguard specific keys
  Optional[Integer]                                               $mark = undef,
  Optional[Variant[Stdlib::Port, Enum['auto']]]                   $port = undef,
  Optional[Array[Struct[{
          Optional['endpoint']        => String[1],
          Optional['allowed_ips']     => Array[Variant[Stdlib::IP::Address, Enum['0.0.0.0/0', '::/0']]],
          Optional['keepalive']       => Integer[1,65535],
          'keys'                      => Struct[{
            'public'                  => String,
            Optional['shared']        => String,
          }],
  }]]]                                                            $peers = undef,
  # VXLAN specific keys
  Optional[Integer[1,16777215]]                                   $id = undef,
  Optional[Integer]                                               $link = undef,
  Optional[Integer]                                               $type_of_service = undef,
  Optional[Boolean]                                               $mac_learning = undef,
  Optional[Integer]                                               $ageing = undef,
  Optional[Integer]                                               $limit = undef,
  Optional[Boolean]                                               $arp_proxy = undef,
  Optional[Enum['l2-miss', 'l3-miss']]                            $notifications = undef,
  Optional[Boolean]                                               $short_circuit = undef,
  Optional[Enum['udp', 'zero-udp6-tx', 'zero-udp6-rx',
                'remote-tx', 'remote-rx ']]                       $checksums = undef,
  Optional[Enum['group-policy', 'generic-protocol']]              $extensions = undef,
  Optional[Tuple[Stdlib::Port, Stdlib::Port]]                     $port_range = undef,
  Optional[Integer[1,1048575]]                                    $flow_label = undef,
  Optional[Boolean]                                               $do_not_fragment = undef,

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

  # show deprecation infos for gateway4 & gateway6
  if $gateway4 != undef {
      notify {"puppet-netplan tunnel ${name}: gateway4 has been deprecated, use default routes instead.": }
  }
  if $gateway6 != undef {
      notify {"puppet-netplan tunnel ${name}: gateway6 has been deprecated, use default routes instead.": }
  }

  $tunnelstmp = epp("${module_name}/tunnels.epp", {
      'name'                           => $name,
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
      'mode'                           => $mode,
      'local'                          => $local,
      'remote'                         => $remote,
      'ttl'                            => $ttl,
      'key'                            => $key,
      'mark'                           => $mark,
      'port'                           => $port,
      'peers'                          => $peers,
      'id'                             => $id,
      'link'                           => $link,
      'type_of_service'                => $type_of_service,
      'mac_learning'                   => $mac_learning,
      'ageing'                         => $ageing,
      'limit'                          => $limit,
      'arp_proxy'                      => $arp_proxy,
      'notifications'                  => $notifications,
      'short_circuit'                  => $short_circuit,
      'checksums'                      => $checksums,
      'extensions'                     => $extensions,
      'port_range'                     => $port_range,
      'flow_label'                     => $flow_label,
      'do_not_fragment'                => $do_not_fragment,
  })

  concat::fragment { $name:
    target  => $netplan::config_file,
    content => $tunnelstmp,
    order   => '61',
  }

}
