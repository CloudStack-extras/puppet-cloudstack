require 'spec_helper'

describe 'cloudstack::cluster', :type => :define do
    let(:title) { 'example42' }
    let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS'
    }}
    let(:params) {{
        :zoneid => 'cloudstack',
        :podid => 'example42'
    }}
    let(:pre_condition) {[
        'include cloudstack',
        'include cloudstack::mgmt',
    ]}
    it { should compile }
end
