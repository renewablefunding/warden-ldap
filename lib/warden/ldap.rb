require "warden/ldap/version"
require "warden/ldap/logger"
require "warden/ldap/configuration"
require "warden/ldap/connection"
require "warden/ldap/strategy"

module Warden
  module Ldap
    class << self
      extend Forwardable
      Configuration.defined_settings.each do |setting|
        def_delegators :configuration, setting, "#{setting.to_s}="
      end

      def configure
        yield configuration if block_given?
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def register
        Warden::Strategies.add(:ldap, Warden::Ldap::Strategy)
      end
    end
  end
end

Warden::Ldap.register

