require 'ostruct'
require 'net/ldap'

module Warden
  module Ldap
    class Strategy < Warden::Strategies::Base
      def valid?
        credentials.all?{|c| c.to_s !~ /^\s*$/}
      end

      def authenticate!
        username, password = credentials
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

      private
      def credentials
        params.values_at('username', 'password')
      end
    end
  end
end
