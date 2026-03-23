# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::bonds' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'bond0' }

      context 'with minimal parameters' do
        let(:params) do
          {
            interfaces: ['eth0', 'eth1'],
            dhcp4:      true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('bond0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '51',
          )
        }
      end

      context 'with bond parameters' do
        let(:params) do
          {
            interfaces: ['eth0', 'eth1'],
            dhcp4:      true,
            parameters: {
              'mode'                   => '802.3ad',
              'lacp_rate'              => 'fast',
              'mii_monitor_interval'   => 100,
              'min_links'              => 1,
              'transmit_hash_policy'   => 'layer3+4',
              'up_delay'               => 200,
              'down_delay'             => 200,
              'learn_packet_interval'  => 5,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('bond0').with_content(
            %r{parameters:},
          )
        }
      end

      context 'with learn_packet_interval as float' do
        let(:params) do
          {
            interfaces: ['eth0', 'eth1'],
            parameters: {
              'mode'                  => 'balance-rr',
              'learn_packet_interval' => 1.5,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'rejects learn_packet_interval as string' do
        let(:params) do
          {
            interfaces: ['eth0', 'eth1'],
            parameters: {
              'mode'                  => 'balance-rr',
              'learn_packet_interval' => 'invalid',
            },
          }
        end

        it { is_expected.to compile.and_raise_error(%r{}) }
      end

      context 'with routing_policy including mark and type_of_service' do
        let(:params) do
          {
            interfaces:     ['eth0', 'eth1'],
            dhcp4:          true,
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => '192.168.0.0/16',
                'mark'            => 10,
                'type_of_service' => 4,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('bond0').with_content(
            %r{mark: 10},
          )
        }
        it {
          is_expected.to contain_concat__fragment('bond0').with_content(
            %r{type-of-service: 4},
          )
        }
      end
    end
  end
end
