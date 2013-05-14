# Warden::Ldap

**NOTE**: This product is still pre-release, and implementation is *not* in sync with documentation yet - hence the pre-release version.  We'll follow [the Semantic Versioning Specification (Semver)](http://semver.org/), so you can assume anything at 0.x.x still has an unstable API.  But we *are* actively developing this.

Adds LDAP Strategy for [warden](https://github.com/hassox/warden) using the [net-ldap](http://net-ldap.rubyforge.org/Net/LDAP.html) library.

## Installation

Add this line to your application's Gemfile:

    gem 'warden-ldap'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warden-ldap

## Usage

1. Install gem per instructions above
2. Initialize the Warden::Ldap adapter:
	
    	Warden::Ldap.configure do |c|
      	  c.config_file = '/absolute/path/to/config/ldap_config.yml'
      	  c.env = 'test'
    	end
    
3. Add the ldap_config.yml to configure connection to ldap server. see lib/fixtures/ldap_config_sample.yml

Note: an optional configuration, `test_environments`, accepts an array of environments to mock, where authentication works as long as username and password are supplies and password is not "fail"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
