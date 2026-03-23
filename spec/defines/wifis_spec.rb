# frozen_string_literal: true

require 'spec_helper'

describe 'netplan::wifis' do
  let(:pre_condition) { 'include netplan' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'wlan0' }

      context 'with minimal parameters' do
        let(:params) { { dhcp4: true } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('wlan0').with(
            'target' => '/etc/netplan/01-netcfg.yaml',
            'order'  => '31',
          )
        }
      end

      context 'with access points' do
        let(:params) do
          {
            dhcp4:         true,
            access_points: {
              'MyNetwork' => {
                'password' => 'secret123',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('wlan0').with_content(
            %r{access-points:},
          )
        }
      end

      context 'with all wakeonwlan values' do
        %w[any disconnect magic_pkt gtk_rekey_failure eap_identity_req
           four_way_handshake rfkill_release tcp default].each do |value|
          context "wakeonwlan #{value}" do
            let(:params) do
              {
                dhcp4:       true,
                wakeonwlan:  [value],
              }
            end

            it { is_expected.to compile.with_all_deps }
          end
        end
      end

      context 'rejects invalid wakeonwlan value' do
        let(:params) do
          {
            dhcp4:      true,
            wakeonwlan: ['invalid_value'],
          }
        end

        it { is_expected.to compile.and_raise_error(%r{}) }
      end

      context 'with routing_policy including mark' do
        let(:params) do
          {
            dhcp4:          true,
            routing_policy: [
              {
                'from'            => '10.0.0.0/8',
                'to'              => 'default',
                'mark'            => 3,
                'type_of_service' => 24,
              },
            ],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('wlan0').with_content(
            %r{mark: 3},
          )
        }
      end
    end
  end
end
