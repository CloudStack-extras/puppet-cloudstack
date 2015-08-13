require 'spec_helper'

describe 'cloudstack' do
    let(:node) { 'cloudstack.example42.com' }
    let(:facts) {{
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '12.10'
    }}

    describe 'generic test' do
        it { should compile }
        it { should contain_class('cloudstack') }
    end
end
