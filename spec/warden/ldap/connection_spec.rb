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

  describe "#ldap_param_value" do
    subject{described_class.new}
    let(:ldap) {Net::LDAP.new}
    let(:entry) {Net::LDAP::Entry.new('ldap_entry')}

    it 'returns value if ldap entry found' do
      Net::LDAP.stub(:new => ldap)
      entry['cn'] = 'code name'
      ldap.should_receive(:search).and_yield(entry)
      subject.logger.should_receive(:info).with('Requested param cn has value ["code name"]')
      subject.ldap_param_value(:cn).should == 'code name'
    end

    it 'returns nil if ldap entry does not have attribute' do
      Net::LDAP.stub(:new => ldap)
      ldap.should_receive(:search).and_yield(entry)
      subject.logger.should_receive(:error).with('Requested param cn does not exist')
      subject.ldap_param_value(:cn).should be_nil
    end

    it 'returns nil if ldap entry not found' do
      Net::LDAP.stub(:new => ldap)
      ldap.should_receive(:search)
      subject.logger.should_receive(:error).with('Requested ldap entry does not exist')
      subject.ldap_param_value(:cn).should be_nil
    end

  end
end
