require 'ostruct'
require 'net/ldap'

module Warden
  module Strategies
    class Ldap < Base
      def valid?
        params['username'] && params['password']
      end

      def authenticate!
        username, password = params.values_at('username', 'password')
        connection = Warden::Ldap::Connection.new({ :username => username, :password => password })
        response = connection.authenticate!

        if response
          user = OpenStruct.new({ :username => username,
                                  :name => connection.ldap_param_value('cn') })
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
