# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::vlans' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'vlan50' }

      context 'with minimal parameters' do
        let(:params) do
          {
            id:    50,
            link:  'eth0',
            dhcp4: true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('vlan50').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '21',
          )
        }
      end

      context 'with static addressing' do
        let(:params) do
          {
            id:        50,
            link:      'eth0',
            addresses: ['192.168.50.10/24'],
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            id:             50,
            link:           'eth0',
            routing_policy: [
              {
                'from'            => '192.168.50.0/24',
                'to'              => 'default',
                'mark'            => 7,
                'type_of_service' => 16,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('vlan50').with_content(
            %r{mark: 7},
          )
        }
      end
    end
  end
end
