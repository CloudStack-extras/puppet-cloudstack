require 'spec_helper'

describe 'cloudstack::zone', :type => :define do
    let(:title) { 'example42' }
    let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS'
    }}
    let(:pre_condition) {[
        'include cloudstack',
        'include cloudstack::mgmt'
    ]}
    it { should compile }
end
