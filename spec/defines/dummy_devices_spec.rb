# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::dummy_devices' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'dummy0' }

      context 'with minimal parameters' do
        let(:params) do
          {
            addresses: ['10.0.0.1/32'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('dummy0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '71',
          )
        }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            addresses:      ['10.0.0.1/32'],
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => 'default',
                'mark'            => 15,
                'type_of_service' => 2,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('dummy0').with_content(
            %r{mark: 15},
          )
        }
        it {
          is_expected.to contain_concat__fragment('dummy0').with_content(
            %r{type-of-service: 2},
          )
        }
      end
    end
  end
end
