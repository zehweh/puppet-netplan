# @summary validates vfr config and writes it to $config_file via concat
#
# @api private
#
# @note intended to be used only by netplan class
#
# Properties for device type vrfs
#
# @param table
#  The numeric routing table identifier. This setting is compulsory.
# @param interfaces
#  All devices matching this ID list will be added to the VRF. This may be an empty list, in which case the VRF 
#  will be brought online with no member interfaces.
#
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
define netplan::vrfs (

  # Properties for device type vrfs
  Integer                                                         $table = undef,
  Array[String[1]]                                                $interfaces = undef,
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
          Optional['to']              => Variant[Stdlib::IP::Address, Enum['default', '0.0.0.0/0', '::/0']],
          Optional['table']           => Integer,
          Optional['priority']        => Integer,
          Optional['mark']            => Integer,
          Optional['type_of_service'] => Integer,
  }]]]                                                            $routing_policy = undef,

) {

  $vrfstmp = epp("${module_name}/vrfs.epp", {
      'name'                           => $name,
      'table'                          => $table,
      'interfaces'                     => $interfaces,
      'routes'                         => $routes,
      'routing_policy'                 => $routing_policy,
  })

  concat::fragment { $name:
    target  => $netplan::config_file,
    content => $vrfstmp,
    order   => '91',
  }
}
