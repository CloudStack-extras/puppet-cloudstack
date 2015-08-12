require 'spec_helper'

describe 'cloudstack::pod', :type => :define do
    let(:title) { 'example42' }
    let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS'
    }}
    let(:params) {{
        :gateway => '127.0.0.1',
        :netmask => '255.255.0.0',
        :startip => '10.0.2.0',
        :endip => '10.2.0.3',
        :zoneid => 'example42'
    }}
    let(:pre_condition) {[
        'include cloudstack',
        'include cloudstack::mgmt'
    ]}
    it { should compile }
end
