module Warden
  module Ldap

    # Stores configruation information
    #
    # Configruation inforamtion is loaded from a configuration block defined within
    # the client application.
    #
    # @example Standard settings
    #   Warden::Ldap.configure do |c|
    #     c.config_file = 'path/to/warden_config.yml'
    #     # ...
    #   end
    #
    class Configuration
      class << self
        def define_setting(name)
          defined_settings << name
          attr_accessor name
        end

        def defined_settings
          @defined_settings ||= []
        end
      end

      define_setting :config_file

      define_setting :env

      define_setting :logger

      def initialize
        @logger ||= Warden::Ldap::Logger
      end

      def env
        if defined? Rails
          Rails.env
        elsif @env.nil?
          raise 'Must define Warden::Ldap.env'
        end
        @env
      end
    end
  end
end
