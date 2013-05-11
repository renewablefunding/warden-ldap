require 'yaml'

module Warden
  module Ldap
    class Connection
      attr_reader :ldap, :login
      def logger
        Warden::Ldap.logger
      end

      def initialize(options= {})
        @login = options.delete(:username)
        @password = options.delete(:password)

        options[:encryption] = config["ssl"].to_sym if config["ssl"]

        @ldap = Net::LDAP.new(options)
        @ldap.host = config["host"]
        @ldap.port = config["port"]
        @ldap.base = config["base"]

        @generic_credentials = config["generic_credentials"]
        @attribute = [config["attributes"]].flatten
      end

      def ldap_param_value(param)
        ldap_entry = nil
        @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}

        if ldap_entry
          if ldap_entry[param]
            logger.info("Requested param #{param} has value #{ldap_entry.send(param)}")
            value = ldap_entry.send(param)
            value = value.first if value.is_a?(Array) and value.count == 1
          else
            logger.error("Requested param #{param} does not exist")
            value = nil
          end
        else
          logger.error("Requested ldap entry does not exist")
          value = nil
        end
      end

      def authenticate!
        if @password
          @ldap.auth(dn, @password)
          @ldap.bind
        end
      end

      def authenticated?
        authenticate!
      end

      def authorized?
        logger.info("Authorizing user #{dn}")
        authenticated?
      end

      def valid_login?
        !search_for_login.nil?
      end

      private
      # Searches the LDAP for the login
      #
      # @return [Object] the LDAP entry found; nil if not found
      def search_for_login
        logger.info("LDAP search for login: #{@attribute}=#{@login}")
        ldap_entry = nil
        @ldap.auth(*@generic_credentials)
        @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}
        ldap_entry
      end

      def ldap_username_filter
        filters = @attribute.map { |att| Net::LDAP::Filter.eq(att, @login) }
        filters.inject { |a,b| Net::LDAP::Filter.intersect(a, b) }
      end

      def find_ldap_user(ldap)
        logger.info("Finding user: #{dn}")
        ldap.search(:base => dn, :scope => Net::LDAP::SearchScope_BaseObject).try(:first)
      end

      def config
        if File.exists?(Warden::Ldap.config_file.to_s)
          @config = YAML.load_file(Warden::Ldap.config_file.to_s)[Warden::Ldap.env]
        else
          {}
        end
      end

      def dn
        logger.info("LDAP dn lookup: #{@attribute}=#{@login}")

        if ldap_entry = search_for_login
          ldap_entry.dn
        end
      end
    end
  end
end
