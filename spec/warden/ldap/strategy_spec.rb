describe Warden::Ldap::Strategy do
  subject {described_class.new(@env)}

  describe '#valid?' do

    it 'returns true if both username and password are passed in' do
      @env = env_with_params("/", {'username' => 'test', 'password' => 'secret'})
      subject.valid?.should be_true
    end

    it 'returns false if password is missing' do
      @env = env_with_params("/", {'username' => 'test'})
      subject.valid?.should be_false
    end

    it 'returns false if password is blank' do
      @env = env_with_params("/", {'username' => 'test', 'password' => ''})
      subject.valid?.should be_false
    end
  end

  describe '#authenticte!' do
    before :each do
      @env = env_with_params("/", {'username' => 'test', 'password' => 'secret'})
      subject.stub(:valid? => true)
    end

    it 'succeeds if the ldap connection succeeds' do
      Warden::Ldap::Connection.any_instance.stub(:authenticate! => true)
      Warden::Ldap::Connection.any_instance.stub(:ldap_param_value).with('cn').and_return('Samuel')
      Warden::Ldap::Connection.any_instance.stub(:ldap_param_value).
        with('mail').
        and_return('Samuel@swiftpenguin.com')
      subject.should_receive(:success!)
      subject.authenticate!
    end

    it 'fails if ldap connection fails' do
      Warden::Ldap::Connection.any_instance.stub(:authenticate! => false)
      subject.should_receive(:fail!)
      subject.authenticate!
    end

    it 'fails if Net::LDAP::LdapError was raised' do
      Warden::Ldap::Connection.any_instance.stub(:authenticate!).and_raise(Net::LDAP::LdapError)
      subject.should_receive(:fail!)
      subject.authenticate!
    end

  end
end
