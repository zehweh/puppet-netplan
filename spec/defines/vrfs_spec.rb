# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::vrfs' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'vrf0' }

      context 'with minimal parameters' do
        let(:params) do
          {
            table:      100,
            interfaces: ['eth0'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('vrf0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '91',
          )
        }
      end

      context 'with routes' do
        let(:params) do
          {
            table:      100,
            interfaces: ['eth0'],
            routes:     [
              {
                'to'     => '10.0.0.0/8',
                'via'    => '192.168.1.1',
                'metric' => 100,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with routing_policy including mark and type_of_service' do
        let(:params) do
          {
            table:          100,
            interfaces:     ['eth0'],
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'table'           => 100,
                'priority'        => 50,
                'mark'            => 33,
                'type_of_service' => 16,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('vrf0').with_content(
            %r{mark: 33},
          )
        }
        it {
          is_expected.to contain_concat__fragment('vrf0').with_content(
            %r{type-of-service: 16},
          )
        }
      end

      context 'with routing_policy without optional to' do
        let(:params) do
          {
            table:          100,
            interfaces:     ['eth0'],
            routing_policy: [
              {
                'from'  => '10.0.0.0/8',
                'table' => 100,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
