describe Warden::Ldap::Connection do
  describe '#authentiate!' do
    it 'does nothing if no password present' do
      subject = described_class.new({'username' => 'bob'})
      subject.authenticate!.should be_false
    end

    it 'authenticates and binds to ldap adapter' do
      subject = described_class.new({:username => 'bob', :password => 'secret'})
      subject.stub(:dn => 'Sammy')
      Net::LDAP.any_instance.should_receive(:auth).with('Sammy', 'secret')
      Net::LDAP.any_instance.should_receive(:bind).and_return(true)
      subject.authenticate!.should be_true
    end

  end
end
