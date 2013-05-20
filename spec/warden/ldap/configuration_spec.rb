describe Warden::Ldap::Configuration do
  describe '#env' do
    it 'returns Rails.env if defined' do
      rails = double(:env => :rails_environemnt)
      stub_const("Rails", rails)
      described_class.new.env.should == :rails_environemnt
    end

    it 'raises error if no environemnt defined' do
      expect{
        described_class.new.env
      }.to raise_error Warden::Ldap::Configuration::Missing
    end
  end

  describe '#test_env?' do
    subject {described_class.new}
    it 'returns true if current env is one of test_environments' do
      subject.test_environments = ['siesta', 'fiesta']
      subject.env = 'siesta'
      subject.test_env?.should be_true
    end

    it 'returns false if current env is one of test_environments' do
      subject.test_environments = ['siesta', 'fiesta']
      subject.env = 'nada'
      subject.test_env?.should be_false
    end

    it 'returns false if test_environemnts is empty' do
      subject.test_environments = []
      subject.env = 'fiesta'
      subject.test_env?.should be_false
    end

    it 'returns false if test_environemnts is undefined' do
      subject.env = 'fiesta'
      subject.test_env?.should be_false
    end
  end
end
