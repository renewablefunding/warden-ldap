require 'ostruct'
require 'net/ldap'
require 'warden'

module Warden
  module Ldap
    class Strategy < Warden::Strategies::Base
      # @public
      # Checks if all credentials have been provided.
      #
      def valid?
        credentials.all?{|c| c.to_s !~ /^\s*$/}
      end

      # @public
      # Performs authentication through the net-ldap library by making a
      # connection to the ldap server specified in the warden_ldap.yml file
      # and with the current credentials.
      #
      # Output:
      #   success: user object constructed as an OpenStruct with username, and name derived from
      #            the 'cn' key in the LDAP directory
      #   failure: nil
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
      # @private
      # extracts the username and password from the params (this is the
      # same params on the RackRequest object which is typically delivered
      # directly from the login form)
      def credentials
        params.values_at('username', 'password')
      end
    end
  end
end
