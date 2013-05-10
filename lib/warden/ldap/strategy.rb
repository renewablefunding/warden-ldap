require 'ostruct'
module Warden
  module Strategies
    class Ldap < Base
      def valid?
        params['username'] && params['password']
      end

      def authenticate!
        u, p = params.values_at('username', 'password')
        l = Warden::Ldap::Connect.new({ :username => u, :password => p })
        a = l.authenticate!

        if a
          user = OpenStruct.new({ :username => u, :name => l.ldap_param_value('cn') })
          success!(user)
        else
          fail!("Could not log in")
        end
      rescue Net::LDAP::LdapError
        fail!("Could not log in")
      end
    end
  end
end
