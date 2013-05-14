describe Warden::Ldap::FakeStrategy do
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
    it 'succeeds if credentials are valid' do
      @env = env_with_params("/", {'username' => 'test', 'password' => 'secret'})
      subject.should_receive :success!
      subject.authenticate!
    end

    it 'fails if password is "fail"' do
      @env = env_with_params("/", {'username' => 'test', 'password' => 'fail'})
      subject.should_receive :fail!
      subject.authenticate!
    end

    it 'fails if credentials are invalid' do
      @env = env_with_params("/", {'username' => 'test', 'password' => ''})
      subject.should_receive :fail!
      subject.authenticate!
    end
  end
end
