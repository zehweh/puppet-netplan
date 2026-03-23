# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::ethernets' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'eth0' }

      context 'with minimal parameters' do
        let(:params) { { dhcp4: true } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('eth0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '11',
          )
        }
      end

      context 'with static addressing' do
        let(:params) do
          {
            addresses: ['192.168.1.10/24', '192.168.1.11/24'],
            nameservers: {
              'search'    => ['example.com'],
              'addresses' => ['8.8.8.8', '8.8.4.4'],
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{addresses:},
          )
        }
      end

      context 'with routes' do
        let(:params) do
          {
            dhcp4:  true,
            routes: [
              {
                'to'     => 'default',
                'via'    => '192.168.1.1',
                'metric' => 100,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{routes:},
          )
        }
      end

      context 'with routing_policy including mark and type_of_service' do
        let(:params) do
          {
            dhcp4:          true,
            routing_policy: [
              {
                'from'            => '192.168.1.0/24',
                'to'              => '10.0.0.0/8',
                'table'           => 100,
                'priority'        => 50,
                'mark'            => 42,
                'type_of_service' => 8,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{routing-policy:},
          )
        }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{mark: 42},
          )
        }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{type-of-service: 8},
          )
        }
      end

      context 'with dhcp4 overrides' do
        let(:params) do
          {
            dhcp4:           true,
            dhcp4_overrides: {
              'use_dns'       => false,
              'use_ntp'       => false,
              'route_metric'  => 200,
              'send_hostname' => true,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('eth0').with_content(
            %r{dhcp4-overrides:},
          )
        }
      end

      context 'with match and set-name' do
        let(:params) do
          {
            dhcp4: true,
            match: {
              'macaddress' => 'AA:BB:CC:DD:EE:FF',
            },
            set_name: 'lan0',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with authentication' do
        let(:params) do
          {
            dhcp4: true,
            auth:  {
              'key_management' => '802.1x',
              'method'         => 'tls',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with openvswitch' do
        let(:params) do
          {
            dhcp4:       true,
            openvswitch: {
              'external_ids' => 'iface-id=myiface',
              'other_config' => 'disable-in-band=true',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with boolean variants for dhcp' do
        let(:params) do
          {
            dhcp4: 'yes',
            dhcp6: 'no',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with all offload options' do
        let(:params) do
          {
            dhcp4:                     true,
            receive_checksum_offload:  true,
            transmit_checksum_offload: false,
            tcp_segmentation_offload:  true,
            tcp6_segmentation_offload: false,
            generic_segmentation_offload:    true,
            generic_receive_offload:         false,
            large_receive_offload:           true,
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
