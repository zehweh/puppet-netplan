# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::bridges' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'br0' }

      context 'with minimal parameters' do
        let(:params) do
          {
            interfaces: ['eth0', 'eth1'],
            dhcp4:      true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('br0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '41',
          )
        }
      end

      context 'with bridge parameters' do
        let(:params) do
          {
            interfaces: ['eth0'],
            parameters: {
              'stp'           => true,
              'forward_delay' => 4,
              'hello_time'    => 2,
              'max_age'       => 20,
              'ageing_time'   => 300,
              'priority'      => 32768, # rubocop:disable Style/NumericLiterals
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('br0').with_content(
            %r{parameters:},
          )
        }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            interfaces:     ['eth0'],
            dhcp4:          true,
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => 'default',
                'mark'            => 5,
                'type_of_service' => 12,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('br0').with_content(
            %r{mark: 5},
          )
        }
        it {
          is_expected.to contain_concat__fragment('br0').with_content(
            %r{type-of-service: 12},
          )
        }
      end
    end
  end
end
