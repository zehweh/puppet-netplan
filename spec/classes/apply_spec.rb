require 'spec_helper'

describe 'netplan::apply' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it {
        is_expected.to contain_exec('netplan_apply')
          .with_command('/usr/sbin/netplan apply')
          .with_logoutput('on_failure')
          .with_refreshonly(true)
      }
    end
  end
end
