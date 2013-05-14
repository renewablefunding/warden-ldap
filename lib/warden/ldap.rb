require "warden/ldap/version"
require "warden/ldap/logger"
require "warden/ldap/configuration"
require "warden/ldap/connection"
require "warden/ldap/strategy"
require "warden/ldap/fake_strategy"

module Warden
  module Ldap
    class << self
      extend Forwardable
      Configuration.defined_settings.each do |setting|
        def_delegators :configuration, setting, "#{setting.to_s}="
      end

      def configure
        yield configuration if block_given?
        Warden::Ldap.register
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def register
        strategy = configuration.test_env? ?
          Warden::Ldap::FakeStrategy :
          Warden::Ldap::Strategy

        Warden::Strategies.add(:ldap, strategy)
      end
    end
  end
end

