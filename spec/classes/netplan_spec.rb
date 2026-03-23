# frozen_string_literal: true

require 'spec_helper'

describe 'netplan' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/netplan').with_ensure('directory') }
        it {
          is_expected.to contain_concat('/etc/netplan/01-netcfg.yaml').with(
            'mode' => '0600',
          )
        }
        it {
          is_expected.to contain_concat__fragment('netplan_header').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '01',
          )
        }
        it {
          is_expected.to contain_exec('netplan_apply').with(
            'command' => '/usr/sbin/netplan apply',
          )
        }
      end

      context 'with purge_config disabled' do
        let(:params) { { purge_config: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/netplan').without_purge }
      end

      context 'with netplan_apply disabled' do
        let(:params) { { netplan_apply: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_exec('netplan_apply') }
      end

      context 'with custom config_file and mode' do
        let(:params) do
          {
            config_file:      '/etc/netplan/99-custom.yaml',
            config_file_mode: '0644',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat('/etc/netplan/99-custom.yaml').with(
            'mode' => '0644',
          )
        }
      end

      context 'with NetworkManager renderer' do
        let(:params) { { renderer: 'NetworkManager' } }

        it { is_expected.to compile.with_all_deps }
      end

      context 'with ethernets' do
        let(:params) do
          {
            ethernets: {
              'eth0' => {
                'dhcp4' => true,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__ethernets('eth0') }
        it {
          is_expected.to contain_concat__fragment('ethernets_header').with(
            'order' => '10',
          )
        }
      end

      context 'with vlans' do
        let(:params) do
          {
            vlans: {
              'vlan50' => {
                'id'   => 50,
                'link'  => 'eth0',
                'dhcp4' => true,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__vlans('vlan50') }
      end

      context 'with bridges' do
        let(:params) do
          {
            bridges: {
              'br0' => {
                'interfaces' => ['eth0', 'eth1'],
                'dhcp4'      => true,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__bridges('br0') }
      end

      context 'with bonds' do
        let(:params) do
          {
            bonds: {
              'bond0' => {
                'interfaces' => ['eth0', 'eth1'],
                'dhcp4'      => true,
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__bonds('bond0') }
      end

      context 'with tunnels' do
        let(:params) do
          {
            tunnels: {
              'tun0' => {
                'mode'   => 'gre',
                'local'  => '10.0.0.1',
                'remote' => '10.0.0.2',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__tunnels('tun0') }
      end

      context 'with dummy_devices' do
        let(:params) do
          {
            dummy_devices: {
              'dummy0' => {
                'addresses' => ['10.0.0.1/24'],
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__dummy_devices('dummy0') }
      end

      context 'with vrfs' do
        let(:params) do
          {
            vrfs: {
              'vrf0' => {
                'table'      => 100,
                'interfaces' => ['eth0'],
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_netplan__vrfs('vrf0') }
      end
    end
  end
end
