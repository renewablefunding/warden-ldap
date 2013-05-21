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
      class Missing < StandardError; end

      class << self
        def define_setting(name)
          defined_settings << name
          attr_accessor name
        end

        def defined_settings
          @defined_settings ||= []
        end
      end

      # path to the config file which is required for connecting to the
      # LDAP server.
      # REQUIRED
      define_setting :config_file

      # Application environment.  Used for determining which
      # environment to use from the YAML config_file
      # defaults to Rails.env if within Rails app
      define_setting :env

      # Logger to use for outputing info and errors.
      # defaults to STDOUT/STDERR
      define_setting :logger

      # Used to provide an array of environemnts to be considered as
      # test environemnts
      define_setting :test_environments

      def initialize
        @logger ||= Warden::Ldap::Logger
      end

      # @public
      # returns the current environment set by the app,
      # defaults to Rails.env if within Rails app and env is not set.
      def env
        @env ||= if defined? Rails
          Rails.env
        elsif @env.nil?
          raise Missing, 'Must define Warden::Ldap.env'
        end
      end

      # @public
      # true if current environemnt is one of the ones listed in test_environements
      def test_env?
        (@test_environments || []).include? env
      end
    end
  end
end
