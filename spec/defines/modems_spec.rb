# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::modems' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'cdc-wdm0' }

      context 'with minimal parameters' do
        let(:params) do
          {
            apn:       'internet',
            dhcp4:     true,
            renderer:  'NetworkManager',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('cdc-wdm0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '81',
          )
        }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            apn:            'internet',
            dhcp4:          true,
            renderer:       'NetworkManager',
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => 'default',
                'mark'            => 20,
                'type_of_service' => 6,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('cdc-wdm0').with_content(
            %r{mark: 20},
          )
        }
      end
    end
  end
end
