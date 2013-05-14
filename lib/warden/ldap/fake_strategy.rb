require 'ostruct'
require 'warden'

module Warden
  module Ldap
    class FakeStrategy < Warden::Ldap::Strategy
      def authenticate!
        username, password = credentials
        if valid? && password.downcase != 'fail'
          user = OpenStruct.new({ :username => username })
          success!(user)
        else
          fail!("Could not log in")
        end
      end
    end
  end
end
