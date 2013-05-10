describe Warden::Ldap do
  before :each do
    described_class.configure do |c|
      c.config_file = File.join(File.dirname(__FILE__), '../fixtures/warden_ldap.yml')
    end
  end

  it 'returns 401 if not authenticated' do
    env = env_with_params("/", {'username' => 'test'})
    app = lambda do |env|
      env['warden'].authenticate(:ldap)
      throw(:warden)
    end
    result = setup_rack(app).call(env)
    result.first.should == 401
    result.last.should == ["You Fail!"]
  end

  it 'returns 200 if authenticates properly' do
    env = env_with_params("/", {'username' => 'bobby', 'password' => 'joel'})
    app = lambda do |env|
      env['warden'].authenticate(:ldap)
      success_app.call(env)
    end
    Warden::Ldap::Connection.any_instance.stub(:authenticate! => true)
    Warden::Ldap::Connection.any_instance.stub(:ldap_param_value).with('cn').and_return('Samuel')
    result = setup_rack(app).call(env)
    result.first.should == 200
    result.last.should == ["You Rock!"]
  end

  it 'returns authenticated user information' do
    env = env_with_params("/", {'username' => 'bobby', 'password' => 'joel'})
    app = lambda do |env|
      env['warden'].authenticate(:ldap)
      success_app.call(env)
    end
    Warden::Ldap::Connection.any_instance.stub(:authenticate! => true)
    Warden::Ldap::Connection.any_instance.stub(:ldap_param_value).with('cn').and_return('Samuel')
    result = setup_rack(app).call(env)
    env['warden'].user.username.should == 'bobby'
    env['warden'].user.name.should == 'Samuel'
  end
end
