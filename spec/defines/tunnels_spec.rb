# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::tunnels' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'tun0' }

      context 'with GRE tunnel' do
        let(:params) do
          {
            mode:   'gre',
            local:  '10.0.0.1',
            remote: '10.0.0.2',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('tun0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '61',
          )
        }
      end

      context 'with WireGuard tunnel' do
        let(:params) do
          {
            mode: 'wireguard',
            key:  'aWd0cE0lKnRiNSNhNjRERCpRYWw0MnE0OCRJM04wSzY=',
            mark: 42,
            port: 51820, # rubocop:disable Style/NumericLiterals
            peers: [
              {
                'keys' => {
                  'public' => 'cHViMStyZWFsbHlsb25na2V5dGhhdGlzdmFsaWQ5OQ==',
                },
                'endpoint'    => '10.0.0.1:51820',
                'allowed_ips' => ['10.10.0.0/24'],
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with VXLAN tunnel' do
        let(:params) do
          {
            mode: 'vxlan',
            id:   42,
            link: 'eth0',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with VXLAN checksums including remote-rx' do
        let(:params) do
          {
            mode:      'vxlan',
            id:        42,
            link:      'eth0',
            checksums: 'remote-rx',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            mode:           'gre',
            local:          '10.0.0.1',
            remote:         '10.0.0.2',
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => 'default',
                'mark'            => 99,
                'type_of_service' => 32,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('tun0').with_content(
            %r{mark: 99},
          )
        }
        it {
          is_expected.to contain_concat__fragment('tun0').with_content(
            %r{type-of-service: 32},
          )
        }
      end
    end
  end
end
